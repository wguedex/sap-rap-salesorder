CLASS zcl_upload_data_sales_order DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
   INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.


ENDCLASS.



CLASS zcl_upload_data_sales_order IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.

    DATA: lt_header TYPE TABLE OF ZHEADER_0780.

    lt_header = VALUE #(
      ( client = '100' ordernumber = '90000001' email = 'john.doe@example.com' firstname = 'John' lastname = 'Doe' country = 'US' createon = '20231001' deliverydate = '20231101' orderstatus = '1' imageurl = 'img001' )
      ( client = '100' ordernumber = '90000002' email = 'jane.smith@example.com' firstname = 'Jane' lastname = 'Smith' country = 'UK' createon = '20231005' deliverydate = '20231106' orderstatus = '2' imageurl = 'img002' )
      ( client = '100' ordernumber = '90000003' email = 'robert.jones@example.com' firstname = 'Robert' lastname = 'Jones' country = 'AU' createon = '20231007' deliverydate = '20231109' orderstatus = '1' imageurl = 'img003' )
      ( client = '100' ordernumber = '90000004' email = 'alice.white@example.com' firstname = 'Alice' lastname = 'White' country = 'CA' createon = '20231010' deliverydate = '20231111' orderstatus = '3' imageurl = 'img004' )
      ( client = '100' ordernumber = '90000005' email = 'charles.green@example.com' firstname = 'Charles' lastname = 'Green' country = 'NZ' createon = '20231012' deliverydate = '20231113' orderstatus = '1' imageurl = 'img005' )
     ).

    DELETE FROM ZHEADER_0780.

    INSERT ZHEADER_0780 FROM TABLE @lt_header.

    out->write( |{ sy-dbcnt } Header entries inserted successfully!| ).

    DATA: lt_items TYPE TABLE OF zitems_0780.

    lt_items = VALUE #(
      ( client = '100' ordernumber = '90000001' positionnumber = '1' name = 'Laptop' description = 'HP Elitebook' releasedate = '20220101' price = '1200.00' height = '2.5' width = '30.5' depth = '25.00' quantity = '1' unitofmeasure = 'PCS' )
      ( client = '100' ordernumber = '90000001' positionnumber = '2' name = 'Mouse' description = 'Wireless Mouse' releasedate = '20220101' price = '25.00' height = '1.5' width = '5.5' depth = '10.00' quantity = '1' unitofmeasure = 'PCS' )
      ( client = '100' ordernumber = '90000002' positionnumber = '1' name = 'Monitor' description = '24 inch LED' releasedate = '20220101' price = '250.00' height = '30.0' width = '50.5' depth = '5.00' quantity = '1' unitofmeasure = 'PCS' )
      ( client = '100' ordernumber = '90000002' positionnumber = '2' name = 'Keyboard' description = 'Mechanical Keyboard' releasedate = '20220101' price = '75.00' height = '3.0' width = '18.0' depth = '45.00' quantity = '1' unitofmeasure = 'PCS' )
      ( client = '100' ordernumber = '90000003' positionnumber = '1' name = 'Tablet' description = 'Samsung Galaxy' releasedate = '20220101' price = '500.00' height = '1.0' width = '15.0' depth = '20.00' quantity = '1' unitofmeasure = 'PCS' )
      ( client = '100' ordernumber = '90000003' positionnumber = '2' name = 'Stylus' description = 'For tablets' releasedate = '20220101' price = '20.00' height = '0.3' width = '0.5' depth = '15.00' quantity = '1' unitofmeasure = 'PCS' )
      ( client = '100' ordernumber = '90000004' positionnumber = '1' name = 'Smartphone' description = 'iPhone 13' releasedate = '20220101' price = '800.00' height = '0.8' width = '7.0' depth = '15.00' quantity = '1' unitofmeasure = 'PCS' )
      ( client = '100' ordernumber = '90000004' positionnumber = '2' name = 'Earbuds' description = 'Wireless Earbuds' releasedate = '20220101' price = '50.00' height = '1.0' width = '6.0' depth = '6.00' quantity = '1' unitofmeasure = 'PCS' )
      ( client = '100' ordernumber = '90000005' positionnumber = '1' name = 'Smartwatch' description = 'Fitbit Versa 3' releasedate = '20220101' price = '200.00' height = '1.2' width = '4.0' depth = '4.00' quantity = '1' unitofmeasure = 'PCS' )
    ).

    DELETE FROM zitems_0780.

    INSERT zitems_0780 FROM TABLE @lt_items.

    out->write( |{ sy-dbcnt } Items entries inserted successfully!| ).

  ENDMETHOD.
ENDCLASS.
