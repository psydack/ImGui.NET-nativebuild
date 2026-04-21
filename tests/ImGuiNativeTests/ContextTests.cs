using Xunit;

public class ContextTests : IDisposable
{
    private readonly IntPtr _ctx;

    public ContextTests()
    {
        _ctx = NativeLib.igCreateContext(IntPtr.Zero);
    }

    public void Dispose() => NativeLib.igDestroyContext(_ctx);

    [Fact]
    public void CreateContext_ReturnsValidPointer()
        => Assert.NotEqual(IntPtr.Zero, _ctx);

    [Fact]
    public void GetIO_AfterCreate_ReturnsValidPointer()
        => Assert.NotEqual(IntPtr.Zero, NativeLib.igGetIO());

    [Fact]
    public void DestroyContext_DoesNotCrash()
    {
        // Destroy is called in Dispose; creating a second context here to
        // verify the call itself is safe independently.
        var ctx2 = NativeLib.igCreateContext(IntPtr.Zero);
        NativeLib.igDestroyContext(ctx2); // must not throw
    }
}
