//Función para obtener de la pantalla los valores de factura_id y cliente_id que se seleccionen
const editSale = (factura_id, cliente_id) => {
    let btneditsale = document.getElementById('btn-selectSale');
    apex.item("P4_FACTURA_ID_SELECTED").setValue(factura_id);
    apex.item("P4_CLIENTE_ID_SELECTED").setValue(cliente_id);
    console.log("seteando valores"+factura_id+","+cliente_id);
    btneditsale.click();
}

//Función para obtener de la pantalla los valores de factura_detalle_id que se seleccionen
function deleteFacturaDetalle(factura_detalle_id){
    apex.item("P5_FACTURA_DETALLE_SELECCIONADO").setValue(factura_detalle_id);
    const btn_select_cliente = document.getElementById("BtnDelFacturaDetalle");
    btn_select_cliente.click();
}

//scripts para asignar la característica de read only a ciertos campos que no deben ser editados
//sino solamente visualizados
document.getElementById("P5_FULLNAME").readOnly = true;
document.getElementById("P5_NIT").readOnly = true;
document.getElementById("P5_FACTURA_ID").readOnly = true;

//Función para validar que el monto a pagar no sea mayor al saldo deudor
function validar_saldo(){
    let model = apex.region("QuotePayments").widget().interactiveGrid("getViews","grid").model;
    let n_dist_amount, n_total = 0;
    let col_gl_amount = model.getFieldKey("MONTO_PAGAR");
    const total = apex.locale.toNumber(apex.item("P7_TOTAL").getValue());

    model.forEach(function(igrow){
        n_dist_amount = apex.locale.toNumber(igrow[col_gl_amount]);
        if(!isNaN(n_dist_amount)){
            n_total += n_dist_amount;
        }
    }
    );

    let saldo_deudor = total-n_total;
    
    console.log("Total: "+total);
    console.log("n_total: "+n_total);
    console.log("saldo_deudor: "+saldo_deudor);

    if(saldo_deudor === 0){
        saldo_deudor = 0;
    }
    if(saldo_deudor<0){
        apex.message.alert("El saldo deudor no puede ser mayor al total. Favor de corregir para poder guardar los cambios");
        apex.item("P7_SALDO").setValue(saldo_deudor);
        $("#btn-add-row").prop("disabled",true);
        $("#btn-save").prop("disabled",true);
    }else{
        if(saldo_deudor==0){
            $("#btn-add-row").prop("disabled",true);
        }else{
            $("#btn-add-row").prop("disabled",false);
        }
        $("#btn-save").prop("disabled",false);
        apex.item("P7_SALDO").setValue(saldo_deudor);
    }
}

