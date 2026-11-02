class CcLimits < Formula
  desc "Claude Code and Codex usage limits in the macOS menu bar"
  homepage "https://cc-limits.morox.ai"
  head "https://github.com/morox-ai/cc-limits.git", branch: "main"

  depends_on macos: :monterey

  def install
    system "bash", "build.sh"
    libexec.install "ClaudeCodeLimits.app", "cc-limits"
    bin.install_symlink libexec/"cc-limits"
  end

  service do
    run [opt_libexec/"ClaudeCodeLimits.app/Contents/MacOS/ClaudeCodeLimits"]
    keep_alive successful_exit: false
    process_type :interactive
  end

  test do
    assert_match "Usage: cc-limits", shell_output("#{bin}/cc-limits --help")
    assert_predicate libexec/"ClaudeCodeLimits.app/Contents/MacOS/ClaudeCodeLimits", :executable?
  end
end
