table 99100 "Sales Order Release Setup"
{
    DataClassification = ToBeClassified;
    Caption = 'Sales Order Release Setup';
    fields
    {
        field(99100; PK; Code[10])
        {
            DataClassification = ToBeClassified;
            InitValue = '';
        }

        field(99101; EnableCreateWhseDoc; Boolean)
        {
            DataClassification = ToBeClassified;
        }

        field(99102; EnableCreatePicks; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(PK; PK)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        // Add changes to field groups here
    }



}

page 99100 "Sales Order Release Setup"
{

    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Sales Order Release Setup";
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(Options)
            {
                field("Enable Warehouse Shipment Document"; Rec.EnableCreateWhseDoc)
                {
                    ApplicationArea = All;
                    Tooltip = 'Creates Warehouse Shipment Document when a Sales Order is Released';
                }

                field("Enable Create Pick"; Rec.EnableCreatePicks)
                {
                    ApplicationArea = All;
                    Tooltip = 'Create a Warehouse Pick when a Warehouse Shipment Document is created. This option is available when "Enable Release" is switched on';
                    Enabled = Rec.EnableCreateWhseDoc;
                }

            }
        }
    }

    trigger OnModifyRecord(): Boolean
    begin
        if not Rec.EnableCreateWhseDoc then
            Rec.EnableCreatePicks := false;
    end;

}

codeunit 99100 InitializeSOReleaseSetup
{

    [EventSubscriber(ObjectType::Page, Page::"Sales Order Release Setup", OnOpenPageEvent, '', true, true)]
    local procedure BlockInsert()
    var
        SOR: Page "Sales Order Release Setup";
        SORTable: Record "Sales Order Release Setup";
    begin
        if SORTable.Get('') then
            exit;
        SORTable.Init();
        SORTable.PK := '';
        SORTable.EnableCreateWhseDoc := false;
        SORTable.EnableCreatePicks := false;
        SORTable.Insert();
    end;
}