namespace Helper
{
    partial class Form1
    {
        /// <summary>
        /// Обязательная переменная конструктора.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Освободить все используемые ресурсы.
        /// </summary>
        /// <param name="disposing">истинно, если управляемый ресурс должен быть удален; иначе ложно.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Код, автоматически созданный конструктором форм Windows

        /// <summary>
        /// Требуемый метод для поддержки конструктора — не изменяйте 
        /// содержимое этого метода с помощью редактора кода.
        /// </summary>
        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(Form1));
            this.segName = new System.Windows.Forms.TextBox();
            this.richTextBox1 = new System.Windows.Forms.RichTextBox();
            this.label1 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.genName = new System.Windows.Forms.TextBox();
            this.conButton = new System.Windows.Forms.Button();
            this.genButton = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // segName
            // 
            this.segName.Location = new System.Drawing.Point(108, 172);
            this.segName.Name = "segName";
            this.segName.Size = new System.Drawing.Size(181, 20);
            this.segName.TabIndex = 2;
            // 
            // richTextBox1
            // 
            this.richTextBox1.Location = new System.Drawing.Point(12, 12);
            this.richTextBox1.Name = "richTextBox1";
            this.richTextBox1.ReadOnly = true;
            this.richTextBox1.Size = new System.Drawing.Size(277, 143);
            this.richTextBox1.TabIndex = 3;
            this.richTextBox1.Text = resources.GetString("richTextBox1.Text");
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(12, 175);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(80, 13);
            this.label1.TabIndex = 4;
            this.label1.Text = "Segment Name";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(12, 201);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(78, 13);
            this.label2.TabIndex = 5;
            this.label2.Text = "Patched Name";
            // 
            // genName
            // 
            this.genName.Location = new System.Drawing.Point(108, 198);
            this.genName.Name = "genName";
            this.genName.ReadOnly = true;
            this.genName.Size = new System.Drawing.Size(181, 20);
            this.genName.TabIndex = 6;
            // 
            // conButton
            // 
            this.conButton.Location = new System.Drawing.Point(12, 237);
            this.conButton.Name = "conButton";
            this.conButton.Size = new System.Drawing.Size(75, 23);
            this.conButton.TabIndex = 7;
            this.conButton.Text = "Connect";
            this.conButton.UseVisualStyleBackColor = true;
            this.conButton.Click += new System.EventHandler(this.b1_Click);
            // 
            // genButton
            // 
            this.genButton.Enabled = false;
            this.genButton.Location = new System.Drawing.Point(214, 237);
            this.genButton.Name = "genButton";
            this.genButton.Size = new System.Drawing.Size(75, 23);
            this.genButton.TabIndex = 8;
            this.genButton.Text = "Generate";
            this.genButton.UseVisualStyleBackColor = true;
            this.genButton.Click += new System.EventHandler(this.button1_Click);
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(301, 272);
            this.Controls.Add(this.genButton);
            this.Controls.Add(this.conButton);
            this.Controls.Add(this.genName);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.richTextBox1);
            this.Controls.Add(this.segName);
            this.Name = "Form1";
            this.Text = "ASL Helper";
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.TextBox segName;
        private System.Windows.Forms.RichTextBox richTextBox1;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.TextBox genName;
        private System.Windows.Forms.Button conButton;
        private System.Windows.Forms.Button genButton;
    }
}

