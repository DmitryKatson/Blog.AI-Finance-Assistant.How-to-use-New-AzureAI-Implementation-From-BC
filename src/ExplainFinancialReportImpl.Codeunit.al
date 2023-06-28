codeunit 50101 "Explain Financial Report Impl."
{
    var
        AccSchedLine: Record "Acc. Schedule Line";
        ColumnLayout: Record "Column Layout";
        UseAmtsInAddCurr: Boolean;
        SuggestedExplanationText: Text;
        ExplainFinancialReportPromptTemplate: label 'You are CFO Assistant.\\Below is the financial report of a company.\\Analyze the financial report, extract key internal risk factors, and key external risk factors.\\Provide a concise explanation of the financial results along with identified risks and recommended actions.\\\\FINANCIAL REPORT\\"""\\%1\\"""\\EXPLANATION\\';

    procedure SetOptions(var AccSchedLineFrom: Record "Acc. Schedule Line"; ColumnLayoutNameFrom: Code[10]; UseAmtsInAddCurrFrom: Boolean)
    begin
        AccSchedLine.CopyFilters(AccSchedLineFrom);
        ColumnLayout.SetRange("Column Layout Name", ColumnLayoutNameFrom);
        UseAmtsInAddCurr := UseAmtsInAddCurrFrom;
    end;


    procedure SuggestExplanation(var SuggestedExplanationText: Text)
    var
        FinancialReportResults: Text;
        AzureOpenAi: Codeunit "Azure OpenAi";
    begin
        FinancialReportResults := CalculateFinancialReportResults(AccSchedLine, ColumnLayout, UseAmtsInAddCurr);
        SuggestedExplanationText := AzureOpenAi.GenerateCompletion(StrSubstNo(ExplainFinancialReportPromptTemplate, FinancialReportResults));
    end;

    local procedure CalculateFinancialReportResults(var AccSchedLine: Record "Acc. Schedule Line"; var ColumnLayout: Record "Column Layout"; UseAmtsInAddCurr: Boolean): Text
    var
        AccSchedName: Record "Acc. Schedule Name";
        FinancialReportResults: TextBuilder;
        GLSetup: Record "General Ledger Setup";
        MatrixMgt: Codeunit "Matrix Management";
        ColumnValue: Decimal;
    begin
        GLSetup.Get();

        // Calculate financial report results
        AccSchedLine.SetFilter(Show, '<>%1', AccSchedLine.Show::No);
        AccSchedName.Get(AccSchedLine.GetRangeMin("Schedule Name"));

        FinancialReportResults.Append('Financial Report name: ');
        FinancialReportResults.Append(AccSchedName.Description);
        FinancialReportResults.AppendLine();
        FinancialReportResults.AppendLine();

        FinancialReportResults.Append('Financial Report parameters: ');
        FinancialReportResults.AppendLine();

        FinancialReportResults.Append('Date period: ');
        FinancialReportResults.Append(AccSchedLine.GetFilter("Date Filter"));
        FinancialReportResults.AppendLine();
        FinancialReportResults.AppendLine();

        FinancialReportResults.Append('Currency: ');
        if UseAmtsInAddCurr then
            FinancialReportResults.Append(GLSetup."Additional Reporting Currency")
        else
            FinancialReportResults.Append(GLSetup."LCY Code");
        FinancialReportResults.AppendLine();
        FinancialReportResults.AppendLine();


        if AccSchedLine.Find('-') then begin
            FinancialReportResults.Append('Row No.');
            FinancialReportResults.Append('\t');
            FinancialReportResults.Append('Description');
            FinancialReportResults.Append('\t');
            if ColumnLayout.Find('-') then
                repeat
                    FinancialReportResults.Append(ColumnLayout."Column Header");
                    FinancialReportResults.Append('\t');
                until ColumnLayout.Next() = 0;
            FinancialReportResults.AppendLine();

            repeat
                FinancialReportResults.Append(AccSchedLine."Row No.");
                FinancialReportResults.Append('\t');
                FinancialReportResults.Append(AccSchedLine.Description);
                FinancialReportResults.Append('\t');
                if ColumnLayout.Find('-') then
                    repeat
                        CalcColumnValue(ColumnValue);

                        FinancialReportResults.Append(MatrixMgt.FormatAmount(ColumnValue, ColumnLayout."Rounding Factor", UseAmtsInAddCurr));
                        FinancialReportResults.Append('\t');
                    until ColumnLayout.Next() = 0;
                FinancialReportResults.AppendLine();

            until AccSchedLine.Next() = 0;
        end;

        exit(FinancialReportResults.ToText());
    end;

    local procedure CalcColumnValue(var ColumnValue: Decimal)
    var
        AccSchedManagement: Codeunit AccSchedManagement;
    begin
        if (AccSchedLine.Totaling = '') or
           (AccSchedLine."Totaling Type" in
            [AccSchedLine."Totaling Type"::Underline, AccSchedLine."Totaling Type"::"Double Underline"])
        then
            ColumnValue := 0
        else begin
            ColumnValue := AccSchedManagement.CalcCell(AccSchedLine, ColumnLayout, UseAmtsInAddCurr);
            if AccSchedManagement.GetDivisionError() then
                ColumnValue := 0
        end;
    end;

}