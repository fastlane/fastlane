module FastlaneCore
  class Interface
    class FastlaneCommonException < FastlaneException; end

    class FastlaneBuildFailure < FastlaneCommonException; end

    class FastlaneTestFailure < FastlaneCommonException; end

    class FastlaneDependencyError < FastlaneCommonException; end
  end
end
