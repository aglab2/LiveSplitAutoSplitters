using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Windows.Forms;
using LiveSplit.ComponentUtil;

namespace Helper
{
    public partial class Form1 : Form
    {
        Process process;
        DeepPointer levelPointer = new DeepPointer("Project64.exe", 0xD6A1C, 0x32DDFA);

        public Form1()
        {
            InitializeComponent();
        }

        private void b1_Click(object sender, EventArgs e) //Connect
        {
            try
            {
                process = Process.GetProcessesByName("project64").First();
                genButton.Enabled = true;
            }catch(InvalidOperationException)
            {
                MessageBox.Show("Can not find Project64!", "Process Error", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
            }
        }

        private void button1_Click(object sender, EventArgs e) //Generate
        {
            if (process == null || process.HasExited)
            {
                MessageBox.Show("Project64 is not available. Try Connnecting again!", "Process Error", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                genButton.Enabled = false;
            }else
            {
                byte currentLevel = levelPointer.Deref<byte>(process);
                genName.Text = segName.Text + " [" + currentLevel.ToString() + "]";
            }
        }
    }
}
