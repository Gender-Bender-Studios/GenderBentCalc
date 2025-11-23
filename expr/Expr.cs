using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using Calc;

namespace CalcUI
{
    public class Context
    {
        public Godot.CanvasItem Canvas { get; }
        public Godot.Font Font { get; }
        public int FontSize { get; }
        public Godot.Color Color { get; }
        public Godot.Color BackgroundColor { get; }
        public Godot.Rect2 Bounding { get; }
        public Godot.Vector2 Margin { get; }

        public Context(Godot.CanvasItem canvas, Godot.Font font, int fontSize, Godot.Color color, Godot.Color backgroundColor, Godot.Rect2 bounding, Godot.Vector2 margin)
        {
            this.Canvas = canvas;
            this.FontSize = fontSize;
            this.Bounding = bounding;
            this.Color = color;
            this.BackgroundColor = backgroundColor;
            this.Font = font;
            this.Margin = margin;
        }

        public Godot.Rect2 ClientArea()
        {
            return new Godot.Rect2(this.Margin, this.Bounding.Size - 2 * this.Margin);
        }
    }

    public class Cursor
    {
        private readonly int[] cycle = [20, 30];
        private int frame = 0;

        private static Godot.Rect2 OFFSET = new Godot.Rect2(-5.0f, -2.0f, 0.0f, 4.0f);

        public void Draw(CalcUI.Context ctx, Godot.Rect2 rect)
        {
            if (frame < cycle[0])
            {
                ctx.Canvas.DrawRect(new Godot.Rect2(rect.Position + OFFSET.Position, new Godot.Vector2(rect.Size.X, ctx.FontSize) + OFFSET.Size), ctx.Color, true);
            }

            frame = (frame + 1) % cycle[cycle.Length - 1];
        }
    }

    public class Node
    {
        public string Text { get; set; }
        public Godot.Vector2 Origin { get; }
        public Displayable Source { get; }

        public Node(Displayable source, Godot.Vector2 origin, string text)
        {
            this.Text = text;
            this.Origin = origin;
            this.Source = source;
        }

        public Godot.Vector2 Measure(CalcUI.Context ctx)
        {
            return ctx.Font.GetStringSize(Text, Godot.HorizontalAlignment.Left, -1.0f, ctx.FontSize, Godot.TextServer.JustificationFlag.None, Godot.TextServer.Direction.Ltr, Godot.TextServer.Orientation.Horizontal);
        }

        public void Draw(CalcUI.Context ctx)
        {
            float width = ctx.ClientArea().Size.X - Origin.X;
            ctx.Canvas.DrawString(ctx.Font, Origin + new Godot.Vector2(0.0f, ctx.FontSize), Text, Godot.HorizontalAlignment.Left, -1.0f, ctx.FontSize, ctx.Color, Godot.TextServer.JustificationFlag.None, Godot.TextServer.Direction.Ltr, Godot.TextServer.Orientation.Horizontal);
        }

        public Godot.Vector2 IndexPos(CalcUI.Context ctx, int index)
        {
            var size = ctx.Font.GetStringSize(Text[..index], Godot.HorizontalAlignment.Left, -1.0f, ctx.FontSize, Godot.TextServer.JustificationFlag.None, Godot.TextServer.Direction.Ltr, Godot.TextServer.Orientation.Horizontal);
            return this.Origin + new Godot.Vector2(size.X, 0);
        }
    }
}



namespace Calc
{
    static class Utils
    {
        public static double[] ToArrayOrNull(this IEnumerable<double?> source)
        {
            // Use a list to buffer valid items as we find them
            var result = new List<double>();

            foreach (var item in source)
            {
                if (item == null)
                {
                    return null; // Return early immediately
                }
                result.Add(item.Value);
            }

            return [.. result];
        }

    }

    public abstract class Displayable
    {
        public abstract CalcUI.Node[] Display(CalcUI.Context ctx, Godot.Vector2 origin);
    }

    public abstract class Expression : Displayable
    {
        public string Raw { get; set; }
        public Expression Parent { get; set; }
        public abstract double? Value();
        public abstract Expression[] Children();

    }

    public class ValueExpr : Expression
    {
        public ValueExpr(string raw)
        {
            this.Raw = raw;
        }

        public ValueExpr(Expression parent, string raw)
        {
            this.Parent = parent;
            this.Raw = raw;
        }

        public override Expression[] Children() => [];
        public override double? Value()
        {
            double val;
            var res = Double.TryParse(this.Raw, out val);

            if (res)
            {
                return val;
            }
            else
            {
                return null;
            }
        }
        public override CalcUI.Node[] Display(CalcUI.Context _, Godot.Vector2 origin) => [new CalcUI.Node(this, origin, Raw)];
        public override string ToString() => Raw;
    }

    public class OperationExpr : Expression
    {
        public FuncExpr Func { get; }
        public Expression[] Parameters { get; }
        public OperationExpr(FuncExpr func, Expression[] parameters)
        {
            this.Func = func;
            this.Parameters = parameters;
        }

        public OperationExpr(Expression parent, FuncExpr func, Expression[] parameters)
        {
            this.Parent = parent;
            this.Func = func;
            this.Parameters = parameters;
            Array.ForEach(Parameters, it => it.Parent = this);
        }


        public override double? Value()
        {
            var arr = Utils.ToArrayOrNull(this.Parameters.Select(x => x.Value()));
            if (arr == null)
            {
                return null;
            }

            return Func.Evaluate(arr);
        }

        public override Expression[] Children() => this.Parameters;
        public override CalcUI.Node[] Display(CalcUI.Context ctx, Godot.Vector2 origin)
        {
            IEnumerable<Displayable> displayables = [];
            switch (Func.Type())
            {
                case FuncExpr.FuncType.PreFix:

                    displayables = displayables.Append(this.Func)
                        .Concat(this.Parameters);
                    break;
                case FuncExpr.FuncType.InFix: // Implies 2 elements
                    displayables = displayables.Append(this.Parameters[0])
                          .Append(this.Func)
                          .Append(this.Parameters[1]);
                    break;
                case FuncExpr.FuncType.PostFix:
                    displayables = displayables.Concat(this.Parameters)
                              .Append(this.Func);
                    break;
            }

            var nodes = displayables.SelectMany(param =>
                {
                    var tmp = param.Display(ctx, origin);
                    var tmpLast = tmp.Last();
                    origin.X = tmpLast.Origin.X + tmpLast.Measure(ctx).X;
                    return tmp;
                });

            return [.. nodes];
        }

        public override string ToString()
        {
            switch (Func.Type())
            {
                case FuncExpr.FuncType.InFix:
                    return $"({Parameters[0]} {Func} {Parameters[1]})";
                case FuncExpr.FuncType.PostFix:
                    {
                        var s = string.Join(" ", Parameters.Select(it => it.ToString()));
                        return $"({s}){Func}";
                    }
                case FuncExpr.FuncType.PreFix:
                    {
                        var s = string.Join(" ", Parameters.Select(it => it.ToString()));
                        return $"{Func}({s})";
                    }
            }

            throw new UnreachableException();
        }
    }

    public abstract class FuncExpr : Displayable
    {
        public enum FuncType
        {
            PreFix,
            InFix,
            PostFix,
        }

        public enum FuncPriority
        {
            OTHER = 0,
            MULTIPLY_DIVIDE = 1,
            ADD_SUBTRACT = 2,
        }

        public abstract FuncType Type();
        public abstract FuncPriority Priority();
        public abstract int Parameters();
        public abstract double Evaluate(double[] parameters);

        public static FuncExpr FromString(string ch)
        {
            switch (ch)
            {
                case "+": return new Addition();
                case "-": return new Subtract();
                case "/": return new Division();
                case "*": return new Multiplcation();
                default: throw new UnreachableException($"No opration like: '{ch}'");
            }
        }


    }


    public class Addition : FuncExpr
    {
        public override int Parameters() => 2;
        public override FuncPriority Priority() => FuncPriority.ADD_SUBTRACT;
        public override double Evaluate(double[] parameters) => parameters[0] + parameters[1];
        public override FuncType Type() => FuncType.InFix;
        public override string ToString() => "+";
        public override CalcUI.Node[] Display(CalcUI.Context _, Godot.Vector2 origin) => [new CalcUI.Node(this, origin, "+")];
    }

    public class Subtract : FuncExpr
    {
        public override int Parameters() => 2;
        public override FuncPriority Priority() => FuncPriority.ADD_SUBTRACT;
        public override double Evaluate(double[] parameters) => parameters[0] - parameters[1];
        public override FuncType Type() => FuncType.InFix;
        public override string ToString() => "-";
        public override CalcUI.Node[] Display(CalcUI.Context _, Godot.Vector2 origin) => [new CalcUI.Node(this, origin, "-")];


    }

    public class Division : FuncExpr
    {
        public override int Parameters() => 2;
        public override FuncPriority Priority() => FuncPriority.MULTIPLY_DIVIDE;
        public override string ToString() => "÷";
        public override double Evaluate(double[] parameters) => parameters[0] / parameters[1];
        public override FuncType Type() => FuncType.InFix;
        public override CalcUI.Node[] Display(CalcUI.Context _, Godot.Vector2 origin) => [new CalcUI.Node(this, origin, "÷")];

    }

    public class Multiplcation : FuncExpr
    {
        public override int Parameters() => 2;
        public override FuncPriority Priority() => FuncPriority.MULTIPLY_DIVIDE;
        public override string ToString() => "×";
        public override double Evaluate(double[] parameters) => parameters[0] * parameters[1];
        public override FuncType Type() => FuncType.InFix;
        public override CalcUI.Node[] Display(CalcUI.Context _, Godot.Vector2 origin) => [new CalcUI.Node(this, origin, "×")];

    }

}
