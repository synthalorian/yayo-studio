require "test_helper"

# Base class for system tests. No system tests exist yet, but the
# test/system directory must be present for `bin/rails test:system`
# (run in CI) to resolve instead of raising LoadError.
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]
end
