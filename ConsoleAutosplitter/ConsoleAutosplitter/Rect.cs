using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;

namespace ConsoleAutosplitter
{
    [StructLayout(LayoutKind.Sequential)]
    public struct RECT
    {
        public int left;
        public int top;
        public int right;
        public int bottom;

        public int Height
        {
            get { return bottom - top; }
            set { bottom = value + top; }
        }
        public int Width
        {
            get { return right - left; }
            set { right = value + left; }
        }
    }
}
