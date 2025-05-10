pageextension 99009 "Sales Order Ext MOO" extends "Sales Order"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        //Create Warehouse Shipment and Generate Pick lines for the current Sales Order when the order is released.
        modify(Release)
        {
            trigger OnAfterAction()
            begin
                CreateWhseShipment();
            end;
        }
    }

    //Creates Warehouse Shipment Doc from Sales Order.
    local procedure CreateWhseShipment()
    var
        GetSourceDocOutbound: Codeunit "Get Source Doc. Outbound";
        SOReleaseSetup: Record "Sales Order Release Setup";
    begin
        SOReleaseSetup.Get('');
        if not SOReleaseSetup.EnableCreateWhseDoc then
            exit;
        GetSourceDocOutbound.CreateFromSalesOrder(Rec);
        if not Rec.Find('=><') then
            Rec.Init();
    end;
}

codeunit 99004 UpdateSourceNo
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Get Source Doc. Outbound", OnAfterCreateWhseShipmentHeaderFromWhseRequest, '', true, true)]
    local procedure CreatePickOnAfterCreateWhseShipmentHeaderFromWhseRequest(WhseShptHeader: Record "Warehouse Shipment Header"; var WarehouseRequest: Record "Warehouse Request")
    var
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
        SOReleaseSetup: Record "Sales Order Release Setup";
    begin
        if (WarehouseRequest.Type = WarehouseRequest.Type::Outbound) and
        (WarehouseRequest."Source Document" = WarehouseRequest."Source Document"::"Sales Order") and
        (WarehouseRequest."Source Subtype" = WarehouseRequest."Source Subtype"::"1") and
        (WarehouseRequest."Source Type" = 37)
        then begin
            SOReleaseSetup.Get('');
            if not SOReleaseSetup.EnableCreatePicks then begin
                ReleaseWhseShiptDoc(WhseShptHeader);
                exit;
            end;
            WarehouseShipmentLine.Reset();
            WhseShptHeader.Reset();
            WarehouseShipmentLine.SetFilter("No.", WhseShptHeader."No.");
            WhseShptHeader.SetFilter("No.", WhseShptHeader."No.");
            CreatePickLines(WarehouseShipmentLine, WhseShptHeader);
            //Release warehouse shipment doc.
            ReleaseWhseShiptDoc(WhseShptHeader);
        end;
    end;

    // Creates Pick Lines from Warehouse Shipment Lines using the "Whse.-Shipment - Create Pick" report. 
    local procedure CreatePickLines(var WhseShptLine: Record "Warehouse Shipment Line"; var WhseShptHeader: Record "Warehouse Shipment Header")
    var
        WhseCreatePickRep: Report "Whse.-Shipment - Create Pick";
        ReportParameters: Text;
    begin
        //Initialize "Whse.-Shipment - Create Pick".SetWhseShipmentLine.
        WhseCreatePickRep.SetWhseShipmentLine(WhseShptLine, WhseShptHeader);
        //Excute Create Pick Report.
        ReportParameters := '<?xml version="1.0" standalone="yes"?><ReportParameters name="Whse.-Shipment - Create Pick" id="7318"><Options><Field name="AssignedIDReq" /><Field name="SortActivity">6</Field><Field name="BreakbulkFilterReq">false</Field><Field name="DoNotFillQtytoHandleReq">false</Field><Field name="ApplyCustomSorting">false</Field><Field name="PrintDocReq">false</Field><Field name="ShowSummary">false</Field></Options><DataItems><DataItem name="Warehouse Shipment Line">VERSION(1) SORTING(Field1,Field2)</DataItem><DataItem name="Assembly Header">VERSION(1) SORTING(Field1,Field2)</DataItem><DataItem name="Assembly Line">VERSION(1) SORTING(Field1,Field2,Field3)</DataItem></DataItems></ReportParameters>';
        WhseCreatePickRep.Execute(ReportParameters);
    end;

    //Releases Warehosue Shipment Document After Creating Picks As Per Customers Request.
    local procedure ReleaseWhseShiptDoc(var WhseShipmentHeader: Record "Warehouse Shipment Header")
    var
        ReleaseWhseShptDoc: Codeunit "Whse.-Shipment Release";
        WhseShipmentPage: Page "Warehouse Shipment";
    begin
        WhseShipmentPage.Update(true);
        if WhseShipmentHeader.Status = WhseShipmentHeader.Status::Open then
            ReleaseWhseShptDoc.Release(WhseShipmentHeader);
    end;
}