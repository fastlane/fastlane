# FastlanePty reports the status of whatever the thread ran last

Not an ordering problem, and not part of fastlane#30184. Found while working on
row E; parked here to be taken on its own.

## The defect

`FastlanePty.spawn_with_pty` reaps the child and then reads the status from `$?`:

```ruby
ensure
  begin
    Process.wait(pid)          # sets $? as a side effect
  rescue Errno::ECHILD, PTY::ChildExited
  end
end
...
status = self.process_status   # reads $?, well after the wait
```

The status travels from the `ensure` block, out through `PTY.spawn`'s block, to
the method body as a thread global rather than as a value. `$?` is only written
when the wait actually happens, so it holds a stale value whenever:

1. the child was already reaped and `Errno::ECHILD` was swallowed,
2. a caller stubbed `Process.wait`, which is what
   `fastlane_core/spec/command_executor_spec.rb` does in order to assert on it,
3. anything else in the same thread ran a subprocess between the wait and the read.

In all three the command reports a **previous command's** exit status. A failure
can look like a success, which is the direction that matters.

`spawn_with_popen` does not have this problem: it already keeps `status = p.value`
in a local. Fixing this would make the two paths agree.

## A candidate fix

`fastlane_pty_wait2.patch` in this directory. `Process.wait2` returns
`[pid, status]`, so the status becomes a local:

```ruby
_reaped_pid, status = Process.wait2(pid)
...
status ||= self.process_status
```

Measured with it applied, `command_executor_spec.rb` was unchanged: 0 failures in
defined order, and 1, 0, 1, 1, 0, 1 across seeds 1 to 6, the same as without it.
So it fixes no currently failing example. Its value is the defect above, not the
suite.

Two caveats. It required retargeting 8 mocks in `command_executor_spec.rb` from
`Process.wait` to `wait2`, so the blast radius is larger than the diff suggests.
And keeping `status ||= self.process_status` as a fallback leaves the stale `$?`
path open for the `ECHILD` case, so it narrows the hole rather than closing it.

## Other ways to get the status

Worth weighing before committing to `wait2`:

- Have the caller of `PTY.spawn` capture the pid and reap it outside the block,
  so there is one owner of the wait.
- Keep `Process.wait` and read `$?` immediately inside the `ensure`, assigning to
  a local there. Smaller diff, no mock retargeting, but still relies on `$?`
  being written, so case 1 and case 2 above remain.
- Give `process_status` an argument so callers pass the status they observed,
  keeping the existing mocking seam intact.

The last one is probably the most conservative and deserves a look first.
