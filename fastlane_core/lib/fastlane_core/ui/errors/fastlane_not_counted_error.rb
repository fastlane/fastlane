module FastlaneCore
  class Interface
    class FastlaneNotCountedFailure < FastlaneException; end

    class FastlaneBuildFailure < FastlaneNotCountedFailure; end

    class FastlaneTestFailure < FastlaneNotCountedFailure; end

    class FastlaneDependencyError < FastlaneNotCountedFailure; end
  end
end
