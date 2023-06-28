pageextension 50100 "Acc. Schedule Overview Ext" extends "Acc. Schedule Overview"
{
    layout
    {
        addfirst(factboxes)
        {
            part(ExplanationTextFactBox; "Explanation Factbox Part")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Explanation Text';
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.ExplanationTextFactBox.Page.SetOptions(Rec, CurrentColumnName, UseAmtsInAddCurr);
    end;
}