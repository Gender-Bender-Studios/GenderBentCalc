using System;
using System.Linq;
using Godot;


public partial class ExprHelper : Godot.Node
{

    private const int CURSOR_WIDTH = 6;
    public Calc.Expression Root { get; set; }
    private CalcUI.Node[] UiTree { get; set; }
    public CalcUI.Context Ctx { get; set; }
    public Godot.Vector2 Origin { get; set; }
    public CalcUI.Node FocusedNode { get; set; }

    private bool UpdateCursor = true;
    private Rect2 CachedCursorRect;
    private CalcUI.Cursor UiCursor = new CalcUI.Cursor();

    public int CursorPos { get; set; }

    private ExprHelper(CalcUI.Context ctx, Godot.Vector2 origin)
    {
        this.Root = new Calc.ValueExpr("");
        this.UiTree = Root.Display(ctx, origin);
        this.FocusedNode = this.UiTree.First();
        this.Origin = origin;
        this.Ctx = ctx;
    }

    public static ExprHelper create(
        Godot.CanvasItem canvas,
        Godot.Font font,
        int fontSize,
        Godot.Color textColor,
        Godot.Color backgroundColor,
        Godot.Rect2 bounding,
        Godot.Vector2 margin
    )
    {
        var ctx = new CalcUI.Context(canvas, font, fontSize, textColor, backgroundColor, bounding, margin);
        return new ExprHelper(ctx, ctx.Margin);
    }

    private void RegenUiTree()
    {
        UiTree = null;
        UiTree = Root.Display(Ctx, Origin);
    }

    private Godot.Rect2 CursorRect()
    {
        if (UpdateCursor)
        {
            UpdateCursor = false;
            var origin = FocusedNode.IndexPos(Ctx, CursorPos);
            var src_size = FocusedNode.Measure(Ctx);
            var dims = new Godot.Vector2(CURSOR_WIDTH, src_size.Y);
            this.CachedCursorRect = new Godot.Rect2(origin, dims);
        }

        return this.CachedCursorRect;
    }

    public void Draw()
    {
        Ctx.Canvas.DrawRect(Ctx.Bounding, Ctx.BackgroundColor, true, -1);
        UiCursor.Draw(Ctx, CursorRect());
        Array.ForEach(this.UiTree, node => node.Draw(this.Ctx));
    }

    public double? Value()
    {
        return this.Root.Value();
    }

    public void BtnPress(string btn)
    {
        UpdateCursor = true;

        const string DIGITS = "0123456789.";

        Godot.GD.Print($"We are in: {FocusedNode.Text}, pressing '{btn}'");

        if (DIGITS.Contains(btn))
        {
            if (FocusedNode.Source is Calc.Expression src)
            {
                // I also don't know why this really crap two-way binding exists,
                // And frankly I don't care.
                src.Raw = src.Raw[..this.CursorPos] + btn + src.Raw[this.CursorPos..];
                FocusedNode.Text = src.Raw;

                this.CursorPos += 1;
                Godot.GD.Print($"Current Position: {CursorPos}");

            }

            this.RegenUiTree();
            return;
        }


        switch (btn)
        {
            case "Left":
                if (this.CursorPos == 0)
                {
                    throw new NotImplementedException("TODO prev node!");
                }

                this.CursorPos -= 1;
                Godot.GD.Print($"Current Position: {CursorPos}");
                return;

            case "Right":
                {
                    if (this.FocusedNode.Source is Calc.Expression src)
                    {
                        if (this.CursorPos == src.Raw.Length)
                        {
                            throw new NotImplementedException("TODO next node!");
                        }
                    }
                }

                this.CursorPos += 1;
                Godot.GD.Print($"Current Position: {CursorPos}");

                return;

            case "+":
            case "-":
            case "*":
            case "/":
                {
                    Godot.GD.Print("OPERATORS");
                    if (this.FocusedNode.Source is Calc.Expression src)
                    {
                        var before = src.Raw[..CursorPos];
                        var after = src.Raw[CursorPos..];

                        var left_part = new Calc.ValueExpr(before);
                        var right_part = new Calc.ValueExpr(after);
                        var op = Calc.FuncExpr.FromString(btn);

                        if (src.Parent == null)
                        {
                            // Replace the whole thingy.

                            Root = new Calc.OperationExpr(op, [left_part, right_part]);
                        }
                        else
                        {
                            var parent = (Calc.OperationExpr)src.Parent;
                            switch (parent.Func.Type())
                            {
                                case Calc.FuncExpr.FuncType.InFix:
                                    if (parent.Parameters[0] == src)
                                    {
                                        // Left-side split.
                                        if (parent.Func.Priority().CompareTo(op.Priority()) < 0)
                                        {
                                            // Right-assoc: We need to do left_part *(op) (right_part *(parent.Func) parent.Param[1])
                                            Calc.OperationExpr grandfather = (Calc.OperationExpr)parent.Parent;

                                            parent.Parameters[0] = right_part;
                                            right_part.Parent = parent;

                                            var new_node = new Calc.OperationExpr(grandfather, op, [left_part, parent]);

                                            // Replace at grandfather.
                                            ReplaceAtParentOrRoot(new_node);
                                        }
                                        else
                                        {
                                            // Left-assoc: We need to do (left_part *(op) right_part) *(parent.Func) parent.Param[1]
                                            var new_lhs = new Calc.OperationExpr(parent, op, [left_part, right_part]);
                                            parent.Parameters[0] = new_lhs;
                                        }
                                    }
                                    else
                                    {
                                        // Right-side split.
                                        if (parent.Func.Priority().CompareTo(op.Priority()) <= 0)
                                        {
                                            // Left-assoc: We need to do (parent.Param[1] *(parent.Func) left_part) *(parent.Func) right_part
                                            Calc.OperationExpr grandfather = (Calc.OperationExpr)parent.Parent;

                                            parent.Parameters[1] = left_part;
                                            left_part.Parent = parent;

                                            var new_node = new Calc.OperationExpr(grandfather, op, [parent, right_part]);

                                            // Replace at grandfather.
                                            ReplaceAtParentOrRoot(new_node);
                                        }
                                        else
                                        {
                                            // Right-assoc: We need to do left_part *(op) (right_part *(parent.Func) parent.Param[1])
                                            var grandfather = parent.Parent;

                                            parent.Parameters[0] = right_part;
                                            right_part.Parent = parent;

                                            var new_node = new Calc.OperationExpr(grandfather, op, [left_part, parent]);

                                            ReplaceAtParentOrRoot(new_node);
                                        }
                                    }
                                    break;
                                case Calc.FuncExpr.FuncType.PostFix:
                                    throw new NotImplementedException("TODO PostFix!");
                                case Calc.FuncExpr.FuncType.PreFix:
                                    throw new NotImplementedException("TODO PreFix!");
                            }
                        }


                        CursorPos = 0;
                        RegenUiTree();
                        FocusedNode = UiTree.FirstOrDefault(n => n.Source == right_part, null);
                    }
                }

                break;
            case "Enter":
                Godot.GD.Print($"Value: {Value()}");
                break;
        }
    }

    private void ReplaceAtParentOrRoot(Calc.Expression node)
    {
        Godot.GD.Print("To Replace: ", node.Parent.ToString());
        Godot.GD.Print("With: ", node.ToString());
        Calc.OperationExpr parent = (Calc.OperationExpr)node.Parent;
        if (parent == null)
        {
            Root = node;
        }
        else
        {
            int i = Array.FindIndex(parent.Parameters, c => c == parent);
            parent.Parameters[i] = node;
        }
    }

}
