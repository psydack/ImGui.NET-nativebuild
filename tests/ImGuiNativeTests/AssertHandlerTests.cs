using Xunit;

/// <summary>
/// Verifies that cimgui_set_assert_handler and cimgui_trigger_test_assert work
/// correctly from .NET P/Invoke.
/// </summary>
public class AssertHandlerTests : IDisposable
{
    private readonly IntPtr _ctx;
    // Field keeps the delegate alive for the lifetime of the test instance,
    // preventing the GC from collecting it while native code may hold a pointer.
    private NativeLib.AssertHandlerDelegate? _handler;

    public AssertHandlerTests()
    {
        _ctx = NativeLib.igCreateContext(IntPtr.Zero);
    }

    public void Dispose()
    {
        NativeLib.cimgui_set_assert_handler(null);
        NativeLib.igDestroyContext(_ctx);
    }

    [Fact]
    public void SetHandler_RegisterAndUnregister_DoesNotCrash()
    {
        _handler = (expr, file, line) => { };
        NativeLib.cimgui_set_assert_handler(_handler);
        NativeLib.cimgui_set_assert_handler(null);
    }

    [Fact]
    public void TriggerTestAssert_WithHandler_FiresCallback()
    {
        string? capturedExpr = null;
        _handler = (expr, file, line) => capturedExpr = expr;

        NativeLib.cimgui_set_assert_handler(_handler);
        NativeLib.cimgui_trigger_test_assert();
        NativeLib.cimgui_set_assert_handler(null);

        Assert.NotNull(capturedExpr);
        Assert.Contains("false", capturedExpr);
    }

    [Fact]
    public void TriggerTestAssert_WithoutHandler_DoesNotCrash()
    {
        // With no handler registered the assert is a silent no-op.
        NativeLib.cimgui_set_assert_handler(null);
        NativeLib.cimgui_trigger_test_assert(); // must not throw or crash
    }
}
