using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ConsoleAutosplitter
{
    class Program
    {
        static void Main(string[] args)
        {
            IntPtr hWnd = ProcessHelper.WinGetHandle("obs");

            for (int i = 0; i < 1000; i++)
            {
                Image img = PrintWindows.PrintWindow(hWnd);
                Console.WriteLine(i);
                //img.Save("aaa.png");
                //Console.ReadKey();
            }
        }
    }
}
