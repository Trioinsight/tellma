﻿using System;
using System.Collections.Generic;
using System.Text;
using System.Text.Encodings.Web;
using System.Threading.Tasks;

namespace Tellma.Api.Templating
{
    //public class TemplatePlanExpression : TemplatePlan
    //{
    //    private TemplexBase _compiled;
    //    private List<string> _outputs;

    //    public TemplatePlanExpression(string expression)
    //    {
    //        Expression = expression;
    //    }

    //    public TemplateLanguage Language { get; }
    //    public string Expression { get; }
    //    public IReadOnlyList<string> Outputs => _outputs ?? throw new InvalidOperationException("[Bug] Attempt to read outputs before generating them.");

    //    public override async IAsyncEnumerable<Path> ComputeSelect(EvaluationContext ctx)
    //    {
    //        _compiled ??= TemplexBase.Parse(Expression);

    //        if (_compiled != null)
    //        {
    //            await foreach (var path in _compiled.ComputeSelect(ctx))
    //            {
    //                yield return path;
    //            }
    //        }
    //    }

    //    public override async Task GenerateOutputs(EvaluationContext ctx)
    //    {
    //        _compiled ??= TemplexBase.Parse(Expression);
    //        _outputs ??= new List<string>();

    //        string output;
    //        if (_compiled != null)
    //        {
    //            var builder = new StringBuilder();
    //            await _compiled.GenerateOutput(builder, ctx);
    //            output = builder.ToString();
    //        }
    //        else
    //        {
    //            output = null;
    //        }

    //        _outputs.Add(output);
    //    }
    //}

    /// <summary>
    /// The leaf node of a plan, contains a single template that is evaluated
    /// once or multiple times into the <see cref="Outputs"/>
    /// collection.
    /// </summary>
    public class TemplatePlanLeaf : TemplatePlan
    {
        private TemplateTree _compiled;
        private List<string> _outputs = new List<string>();

        /// <summary>
        /// Create a new instance of the <see cref="TemplatePlanLeaf"/> class.
        /// </summary>
        public TemplatePlanLeaf(string template, TemplateLanguage language = TemplateLanguage.Text)
        {
            Template = template;
            Language = language;
        }

        /// <summary>
        /// The <see cref="TemplateLanguage"/> of this plan's template.
        /// </summary>
        public TemplateLanguage Language { get; }

        /// <summary>
        /// The template to execute.
        /// </summary>
        public string Template { get; }

        /// <summary>
        /// The output result(s) after evaluating the template. There is usually
        /// one result unless this plan is inclosed within one or more <see cref="TemplatePlanForeach"/>s. <br/>
        /// Attempting to read this property before evaluating the template will throw an <see cref="InvalidOperationException"/>.
        /// </summary>
        /// <exception cref="InvalidOperationException"></exception>
        public IReadOnlyList<string> Outputs => _outputs;

        public override async IAsyncEnumerable<Path> ComputeSelect(EvaluationContext ctx)
        {
            _compiled ??= TemplateTree.Parse(Template);

            if (_compiled != null)
            {
                await foreach (var path in _compiled.ComputeSelect(ctx))
                {
                    yield return path;
                }
            }            
        }

        public override async Task GenerateOutputs(EvaluationContext ctx)
        {
            _compiled ??= TemplateTree.Parse(Template);
            _outputs ??= new List<string>();

            string output;
            if (_compiled != null)
            {
                var builder = new StringBuilder();
                Func<string, string> encodeFunc = Language switch
                {
                    TemplateLanguage.Html => HtmlEncoder.Default.Encode,
                    TemplateLanguage.Text => s => s, // No need to encode anything for a text output
                    _ => s => s,
                };

                await _compiled.GenerateOutput(builder, ctx, encodeFunc);
                output = builder.ToString();
            }
            else
            {
                output = null;
            }

            _outputs.Add(output);
        }
    }
}
