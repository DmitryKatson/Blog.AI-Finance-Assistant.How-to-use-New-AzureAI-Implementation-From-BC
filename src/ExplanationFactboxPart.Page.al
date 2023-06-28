page 50101 "Explanation Factbox Part"
{
    ApplicationArea = All;
    Caption = 'Explanation Text';
    DelayedInsert = true;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = CardPart;
    Extensible = false;
    RefreshOnActivate = true;

    layout
    {
        area(content)
        {
            group(ExplanationTextGroup)
            {
                Caption = 'Explanation Text';
                ShowCaption = false;

                field(SuggestedExplanationText; SuggestedExplanationText)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                    MultiLine = true;
                    Style = Standard;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Suggest)
            {
                ApplicationArea = All;
                Caption = 'Explain';
                Image = SparkleFilled;
                ToolTip = 'Let Azure OpenAI explain the financial report';

                trigger OnAction()
                begin
                    ExplainFinancialReportImpl.SuggestExplanation(SuggestedExplanationText);
                end;
            }
            action(Detailed)
            {
                ApplicationArea = All;
                Caption = 'Detailed';
                Image = Text;
                ToolTip = 'Detailed explanation';

                trigger OnAction()
                var
                    ExplanationRichText: Page "Explanation Rich Text";
                begin
                    ExplanationRichText.SetExplanationText(SuggestedExplanationText);
                    ExplanationRichText.RunModal();
                end;
            }
        }
    }

    var
        ExplainFinancialReportImpl: Codeunit "Explain Financial Report Impl.";
        SuggestedExplanationText: Text;

    procedure SetOptions(var AccSchedLineFrom: Record "Acc. Schedule Line"; ColumnLayoutNameFrom: Code[10]; UseAmtsInAddCurrFrom: Boolean)
    begin
        ExplainFinancialReportImpl.SetOptions(AccSchedLineFrom, ColumnLayoutNameFrom, UseAmtsInAddCurrFrom);
    end;

}