Welcome to The Monitor Release 4.7 Build 20070413 Released 04/13/07

Contents:
=========
I.	How to contact Computer Decisions International, LLC.
II.	Special Instructions
III.	Installation Instructions
IV.	Enhancements/fixes since v4.0

IMPORTANT NOTICE
================

Effective October 1, 2003, CDI-USA will support only MONITOR versions of 4.2000.410 and above.  
We encourage those who are at 4.0.19991015 or below to make arrangements to upgrade to our most 
current version.

As we continue to offer annual upgrades and quarterly service packs, it is becoming more 
difficult to provide quality support and service of the older versions.  We need to be able to 
dedicate our time and efforts to new enhancements and features that will better serve you and 
your business.  

If you need assistance with an upgrade, remember that phone support is provided by your 
contract. On-site assistance is also available at the current hourly rate.  For further 
information, please contact Andre or Harish at 248 347-4600.


I.	Contacting Computer Decisions International, LLC.
=========================================================
Computer Decisions International, LLC. can be reached by calling (248) 347-4663 or on
the web at www.cdi-usa.com


II.	Special Instructions
============================
*	If you have any custom triggers or procedures, be sure to re-apply them
	to your	database once you have run the update scripts.
*	Customers with voluminous data make sure to drop the audit_trail, order_detail and
	shipper_detail triggers before running the script. After the script is run, make
	sure to put the triggers back onto the db.
*	People who have utilized the database security, please make sure that public group
	is a member of dbo group.


III.	Installation Instructions
=================================
*	Make a copy of your Monitor folder before running the setup program. Be sure to keep 
	a copy of your existing mll.pbd handy.
*	To Install on Windows 98: Run vbrun60sp3.exe from the CD.
*				  If you do not run the above mentioned file, the installation 
				  program may give an error when trying to register en6.ocx.
*	Run Setup program. This must be run on all the Monitor workstations.
*	Put your existing mll.pbd back into the Monitor folder.
*	After running the installation program, make sure to run the related scripts. This 
	should be done once for each database.
	
		Run the script file ending with _sqlany if your database is SQLAnywhere.
		Run the script file ending with _mssql if your database is MS SQL Server.

		Upgrading from 4.6.20041231	     -> Run	scriptchanges_47_sqlany.sql
									 or
							Run	scriptchanges_47_mssql.sql 

		Upgrading from 4.5.20031231/sp453    -> Run	scriptchanges_46_sqlany.sql
								scriptchanges_47_sqlany.sql 
									 or
							Run	scriptchanges_46_mssql.sql 
								scriptchanges_47_mssql.sql 

		Upgrading from 4.5.20031231/sp452    -> Run	scriptchanges_453_sqlany.sql 
								scriptchanges_46_sqlany.sql 
								scriptchanges_47_sqlany.sql 									
									 or
							Run	scriptchanges_453_mssql.sql 
								scriptchanges_46_mssql.sql
								scriptchanges_47_mssql.sql 								 

		Upgrading from 4.5.20031231/sp451    -> Run	scriptchanges_452_sqlany.sql
								scriptchanges_453_sqlany.sql
								scriptchanges_46_sqlany.sql
								scriptchanges_47_sqlany.sql 								 									
									 or
							Run	scriptchanges_452_mssql.sql
								scriptchanges_453_mssql.sql
								scriptchanges_46_mssql.sql 
								scriptchanges_47_mssql.sql 								

		Upgrading from 4.5.20031231	     -> Run	scriptchanges_451_sqlany.sql 
								scriptchanges_452_sqlany.sql
								scriptchanges_453_sqlany.sql
								scriptchanges_46_sqlany.sql
								scriptchanges_47_sqlany.sql 									
									 or
							Run	scriptchanges_451_mssql.sql 
								scriptchanges_452_mssql.sql
								scriptchanges_453_mssql.sql
								scriptchanges_46_mssql.sql
								scriptchanges_47_mssql.sql 								

		Upgrading from 4.4.20021231/sp443
		 or            4.4.20021231/sp442		
		 or            4.4.20021231/sp441
		 or	       4.4.20021231
		 or	       4.3.20011231/sp433
		 or	       4.3.20011231/sp432
		 or	       4.3.20011231/sp431    -> Run	monitor4_upgrade_sqlany.sql
									 or
							Run	monitor4_upgrade_mssql.sql

		Upgrading from 4.0.2000410/814/sp424 
		or earlier version		     -> Run	audit_trail_changes.sql
							Run	monitor4_upgrade_sqlany.sql 
									or 
							Run	monitor4_upgrade_mssql.sql
							
*	Copy updates.exe file or files in the updates folder to either a temp folder or Monitor 
	installed folder. Unarchieve the files by double clicking (if it is a exe file) on the 
	updates.exe file. Files are extracted into a updates sub folder in the current directory.
	Copy the pbd files (if any) to monitor installed folder and run the scripts file (if 
	any) on the database.
	
IV.	Enhancements/Bug Fixes
==============================

4.7 Release Build 20070413
--------------------------

Price updates in sales order and part master
--------------------------------------------
*	This problem has been resoled.
*	The decimal places has been increased to blanket price under part master/part customer screen.


Filter Screens in Administrative Module
---------------------------------------
*	Error on clicking the search button has been suppressed.


Global Shipping Scheduler
-------------------------
*	The popup window has been moved to the right.


Customer Service
----------------
*	RMA invoces do not appear because there is no invoice number assisnged to the same.
*	Manual Invoices do apprear on the invoice registry.


4.6 Release Build 20041231
--------------------------

Security
--------
*	Security feature has been enhanced to sub menus in The Monitor module (13766 ).


Standard Costing
----------------
*	Costing module has been enhanced to input outside cost (13765).


Sales Order
-----------
*	Problem with certain order header data not being carried to detail when modified has been fixed (13762). 
*	Price effectivity date (13767).

Shipping Dock
-------------
*	Supress printing of documents if the custom is on hold (13763).

Utilities
---------
*	Ability to Run SQL Queries from with in the Application. (Only The Monitor Administartive module 
	and Monitor Utilities module) (13760).
*	Audit trail acrhive for a specified date range into a archive table (13768).

ShopFloor
---------
*	Ability to specify No. of Objects during Job Completion (13761).
*	Re-sequencing issue in shopfloor (13764). 




4.5 Build 20031231 Service Pack 4.5.3
-------------------------------------


Standard Costing
----------------
*	Users have the ability to calculate standard cost on obsolete part (137).


Inventory Control
-----------------
*	Weight calculation during a breakout transaction has been fixed ( 137).



4.5 Build 20031231 Service Pack 4.5.2
-------------------------------------

The Monitor
-----------
*	Inquiry screen allows to filter by numeric fields (13748).
*	Unable to save ECN in part master (13749).

Sales Orders
------------
*	Users have the ability to store promise date in sales order screen (13572).

Purchasing
----------
*	Users have the ability to store promise date and other charges in the PO entry screens (13156).




4.5 Build 20031231 Service Pack 4.5.1
-------------------------------------

Production grid
---------------
*	Creating workorders through grid allows more than 6 digits for quantity (13742).

Invoicing
---------
*	Invoicing screen doesn't show return to vendor shippers (13743).

Labels Printing
---------------
*	Label printing issue has been resolved (13740).


Ordervalidation
---------------
*	Order validation is compatible with MSSQL 2000 (13744).


Shipping Dock
-------------
*	Unable to generate asn during ship out on mssql 2000 (13745).

Shopfloor
---------
*	Performance issue in material issue screen has been resolved (13746).




4.5 Build 20031231
------------------

Setups
------
*	Customer price changes can be applied to the open orders, shippers and un-printed invoices (13735).

Sales Orders
------------
*	Destination is editable in both blanket and normal order entry screens (13718, 13721).
*	Users have the ability to put an order on hold and restrict all further 
	transactions (13722).
*	Problem with customer part number & unit of measure not showing up in the popup 
	box on the GSS grid & also in the quick data entry screen has been resolved (13725).
*	Multiple releases are displayed in the GSS grid	(13730).
*	Users have the ability to update setups, open shippers and un-printed invoices with price changes (13735).
	
Invoicing
---------
*	Users have the ability to change the destination in invoicing screen (13727).
*	Problem with total cost getting set to 0 during editing of a invoice has been
	 resolved (13733).

	
Production Scheduling
---------------------
*	Users have the visibility on the assigned or queue quantity in both the grids.


Purchasing
----------
*	Unit of measure drop down is available in the batch release creation on 
	both normal and blanket POs (13715).
*	Smart PO process printing range format has been fixed (13728).	


Receiving
---------
*	Watch dog error during a RMA receipt transaction has been resolved (13732).


Inventory Control
-----------------
*	Cost calculation on combined object has been fixed (13724).


Packing Line
------------
*	Monitor watchdog error while performing completions and printing a pallet 
	has been supressed (13723).


Shipping Dock
-------------
*	Users have the ability to change the destination in the bill of lading screen (13652).
*	Monitor watchdog error while staging to a pallet has been resolved (13719).
*	Problem with scanning of a pallet serial during a verifyscan process mixing up the 
	scanned serial with the dataidentifier has been resolved (13720).
*	Users have the ability to change the destination in shipping dock screen (13727).
*	Problem with shipout routine not update std quantity on order detail if unit
	 conversion exists has been fixed (13729).
*	Multiple releases are stored in the database to be used in the forms (13730).


Shop Floor
----------
*	Problem with reasons for a group code during downtime entry has been fixed (13726).
*	Blank reason code problem has been resolved during downtime entries ( 13731).
*	Problem with workorder # not being written to downtime entries has been 
	 resolved ( 13731).
*	Users have the ability to issue parts in a different defined unit of measure (13734).


Reports and Listings
--------------------
*	Users have the ability to generate ship history report (13716).
*	Users have the ability to generate short shipments report (13717). 
*	Users have the ability to generate a defects report by part (13736).
*	Users have the ability to generate a downtime report by machine (13736).
*	Users have the ability to generate a downtime report by part (13736).
*	Users have the ability to generate a work order status report (13736).



4.4 Build 20021231 Service Pack 4.4.3
-------------------------------------

Part Setup
----------
*	Changing standard unit in part master will re-calculate the std qty in related flow 
	routers if unit conversion is associated with that part (13710).

Order Entry
-----------
*	Users have the ability to filter destinations/demand by plant in GSS (13713).


Purchasing
----------
*	Datawindow retrieval during batch releases creation under POs has been resolved (13707).


Receiving Dock
--------------
*	Ability to receive more than one part problem has been resolved (13712).
*	Data getting cleared from the screen during receiving transaction has been 
	resolved (13708).
	
Shopfloor
---------
*	Unit conversion issue during material issue transaction has been resolved (13650).


Shipping Dock
-------------
*	Error while trying to print a pallet label has been resolved (13709).


Reports
-------
*	GSS reports weekly mode problem has been resolved (13714).



4.4 Build 20021231 Service Pack 4.4.2
-------------------------------------

Security
--------
*	Modifying a module access permision problem has been fixed (13698). 

Order Entry
-----------
*	Sales order inquiry screen display has been fixed (13694).
*	Invoice inquiry screen display has been fixed (13694).
*	Release  number issue has been fixed (13696).
*	Cs_status not getting updated in manual invoice adding and editing (13699).
*	Proper heading is displayed on the due date column in blanket orders (13700).
*	Overlap time is considered correctly in the runtime and due date 
	calculations (13702).

Purchasing
----------
*	PO inquiry screen display has been fixed (13694).
*	Pricing issue has been fixed (13701).

Receiving Dock
--------------
*	Unable to receive more than one part on a PO problem has been fixed ( 13704).

Inventory Control
-----------------
*	Weight calculations during a break out transaction is fixed (13697). 

Shipping Dock
-------------
*	BOL getting closed upon shipout even though there are mulitple shippers on the
	BOL (13703).

Shop Floor
----------
*	Partial material issue problem has been fixed (13705).
	

4.4 Build 20021231 Service Pack 4.4.1
-------------------------------------

Small Setups
------------
*	Users have the ability to enter a default value to a each of the sub category 
	for a given category (13637).
	
Part Master
-----------
*	Removed the un-necessary messagebox during a fast copy functinality.

Order Entry
-----------
*	Internal changes to a gloabl function call to display the icons correctly.
*	Second retrieval argument has been included to overcome the retrieval argument error.
*	Inquiry screen allows to filter for normal orders too through blanket part (13689).

Customer Service
----------------
*	Customer service status not getting populated through RMAs has been fixed (13691).

Purchasing
----------
*	Problem with part vendor price matrix not being considered when editing line item on 
	normal po has been resolved (13669).
*	Inquiry screen allows to filter for normal orders too through blanket part (13689).	
	
Production Scheduling
---------------------
*	The out of memory problem during netout has been resolved (13675).
*	Problem with creating work orders from the last line of the grid not refreshing, 
	reflecting the correct values has been resolved (13674).
*	Planning board has been made scalable giving more flexibility to the system (13681).	
	
Shop Floor
----------
*	Labor logged history shows the correct data now (13676).
*	Correct machine is assigned to the labor entries (13677).
*	Datawindow error has been supressed while going into the inventory screen.
*	Un-issue of materials in shopfloor will put back to the location it came from (13678).
*	Process button now displays documents pertaining to that workorder (part) (13682).
*	Problem with material issue and un-issue loosing some data like vendor code, 
	shipper#, price columns have been fixed (13685).

Shipping
--------
*	Problem with shipout routine closing blanket orders eventhough there are line items 
	on the order has been resolved (13673).
*	Problem with wrong account codes being assigned to purchased part in invoices
	has been resolved ( 13683).
*	Customer service status not getting populated in manual invoices has been fixed (13691).
*	In correct time portion in the date shipped column has been fixed (13690).
	
Utilities
---------
*	Users have the ability to change a part# from one to another globally in multiple 
	flow routers (13650).
*	Users have the ability to change the description in all the tables, when the part 
	master/part description is changed (13651).
	
Reports and Listings
--------------------
*	Users now have the ability to filter sales order reports by salesman (13683).
*	Incorrect Onhand value has been correct in the po comparision report (13692).

	
4.4 Build 20021231
------------------

Monitor
-------
*	Menu level security has been added to the Administrative (The Monitor) 
	module. Only the users who are granted access can use those buttons (13666).
	
Part Master
-----------
*	Users now has the ability to enter blanket price from part master customer price 
	matrix (13627).
*	Editing a BOM component on MSSQL 2000 database has been resolved.	

Order Entry
-----------
*	Global shipping scheduler no longer shows the RMA shippers in the list of shippers 
	scheduled against that destination (13655).
*	The drop down destination list in normal order screen is now sorted by destination
	(13656).
*	GSS has been made date sensitive while applying the committed quantity (13662).		
*	Problem with GSS not showing the open shippers for the clicked destination has been
	resolved ( 13665).
*	Problem with ASN control centre giving a watch dog error when invoked through 
	shipping dock at the time of ship out has been resolved (13667).
		
Customer Service
----------------
*	Problem with the contacts drop down list in contacts call log has been fixed (13659).
*	Problem with customer service not working if there are spaces in the customer code
	has been resolved (13668).
	
Purchasing
----------
*	A basic vendor performance rating based on the AIAG standards has be added 
	(13626, 13658).
*	Problem with smart po process screen giving bad runtime function has been fixed
	(13660).	

Packing Line
------------
*	The null object reference when trying to bring an existing pallet in packing line
	has been resolved (13649).
	
Production Scheduling/Planning
------------------------------
*	Minimum due date from order detail is writting to the work order, so that it will 
	be more appropriate in the planning board display (13654).
*	Users now have the capability to close work orders at the supervisor level, but based 
	on a switch (13657). (NOTE: Any user with a operator level of 0 is consider as 
	supervisor level). 
	
Receiving Dock
--------------
*	Receiving dock now considers the objects present in custom pbl (13610).
*	Wrong vendor code being assigned to the receipts & audit trail has been
	resolved (13623).
*	Screen refreshal problem has been resolved after the order quantity has been
	received and the line item is closed. 

Shipping Dock
-------------
*	Problem with setting BOL status to 'O' when multiple shippers are associated has 
	been resolved (13590).
*	Carrier code and shipper date stamp is considered while assigning Bill of Lading 
	to different shippers(13661).

Shop Floor
----------
*	Sytax error in Inventory screen in shop floor module on MSSQL 2000 has been 
	resolved (13624).
*	Defects graphs has been modified to show correct results (13664).
*	The watchdog error under downtime entry undo functionality has been resolved.
*	Password is being validated when users access downtime entry more than ones.

Super Cop
---------
*	Overlap time or gap time is more meaning fully in the dead start computation (13653).

	Overview: 
		Starting in Monitor 4.4 (December 2002), we have a new way of handling overlap 
		of operations for scheduling. The fields for overlap will now be interpreted 
		as gap times between the start times or end times of the operation flagged and 
		the next operation. The start time for the current operation will be determined 
		by comparing the length of the current operation with the length of the next 
		operation. If the current operation is longer, it will be scheduled to complete 
		X hours before the next operation completes. (We are using X hours to indicate 
		the gap time.) If the current operation is shorter or both operations are the 
		same length, then it will start X hours before the following operation starts.

		If there is no gap value or the gap value is greater than the run time for the 
		current operation, then the standard time calculation will be used. The run time 
		of the current operation will be calculated, and the operation will start that 
		long before the next operation.

		If the overlap type is set to standard pack, then the time to produce one 
		standard pack will be the gap time.

		NOTES:
			To use this overlap accurately, enter expected throughput for all 
			operations, not potential throughput. If you are running parts through 
			a series of operations that are forced to run at the same rate, that 
			is the rate that should be stored in Monitor. Otherwise Monitor will 
			tell you to keep the faster work center freed up until it needs to 
			start.

Executor
--------
*	Problem with Executor loading wrong data if there are missing lines in the flat file
	has been resolved (13633).	
*	Problem with Executor not processing data when the intermediate table had a column 
	by name date has been resolved (13640).

Reports
-------
*	A new report global shipping scheduler report has been included (13662).

*NOTE:*	Use maces.exe to set up Monitor menu access to various users


Build 4.3.20011231 Service Pack 3 (ie 4.3.3)
------------------ -------------------------

Part Customer Price Matrix (Profile)
------------------------------------
*	System now checks whether a price break exist for the customer part being deleted, if 
	so warns the user (13634).

Part Master
-----------
*	Watch dog error going into a specific issue through part master has been suppressed
	(13642).
*	Problem with Part inquiry syntax error on mssql 2000 has been fixed (13621).

Global Shipping Scheduler
-------------------------
*	The problem with release number not getting updates has been resolved.
	
Invoicing
---------
*	The problem while adding lines items manually to a invoice was writing invalid data 
	to shipper detail. This has been fixed ( 13638).

Customer Service 
----------------
*	Deleting an RMA use to remove the shipper data from the database. This has been modified 
	to retain the data and change the status on the rma shipper to E (13641).

Purchasing
----------
*	System defaulting to a value 1 for price column upon editing quantity or balance in 
	blanket po entry screen has been fixed (13636).
*	PO line items will not mix up the price if the currencies are different (13645).	


Packing Line
------------
*	Problem with packing line assigning a value 0 to suffix column in object table has
	been resolved (13646).
			
Shipping Dock
-------------
*	Customer has the ability to enter the actual date shipped at the time of performing
	a ship out (13597)
*	System will warn the user if the part being staged to a shipper is not defined in the
	part customer profile (13598)
*	Ship out writing the wrong release no and date has been fixed (13635).


Shop Floor
----------
*	Problem with inventory screen in shopfloor syntax error has been fixed ( 13624).

Receiving Dock
--------------
*	The vendor code is being validated against the PO number selected while doing a
	receiving transaction in Monitor (13623)
	
Production Scheduling/Planning Board
------------------------------------
*	Manual workorders now saves the data properly (13629)
*	Primary machine is defaulted in the manual workorder entry screen (13631)


Monitor Production Data Collection
----------------------------------
*	The error while editing an existing labor entry has been suppressed (13644).

Order Validation
----------------
*	Problem with saving data in ordervalidation has been fixed (13639)

Standard Reports
----------------
*	Three more reports have been added to our standard reports library



Build 4.3.20011231 Service Pack 2 (ie 4.3.2)
------------------ -------------------------

Order Entry
-----------
*	Part number column now allows 25 characters compared to 21 characters (13615)
*	Bitmaps are displayed properly depending on whether cop needs to be processed 
	or not (13582)
*	Problem with sales/edi screen setting blanket orders to status 0 has been fixed.


Costing
-------
*	Now displays the correct visual bill of material ()


Inventory Control
-----------------
*	A location is written to a pallet created through breakout and any object on that
	pallet will inherit the pallet location (13594)
*	The problem with key pads not working in the job complete screen has been resolved 
	(13609).


Invoicing
---------
*	Filtering on a date problem has been fixed ( 13604)
*	Sql error has been supressed ()


Packing line
------------
*	A location is written to a pallet created and any object on that
	pallet will inherit the pallet location (13594)


Receiving Dock
--------------
*	Correct package type is displayed while receiving an out serial (13596)
*	PO numbers are sorted in the drop down list in the receiving screen (13599)
	

Production Grid
---------------
*	Demand status screen shows the correct percentages in the graph ()
*	Locking issue has been resolved ()


Shipping Dock
-------------
*	The performance issue while staging objects has been resolved (13616)
*	BOL can be re-printed upon modifying a shipper associated to that BOL (13590)
*	ASN generation problem has been resolved ( 13606)
*	Overstaging message has been fixed ( 13616)

Standard Reports
----------------
*	Four more reports have been added to our standard reports library


Build 4.3.20011231 Service Pack 1 (ie 4.3.1)
------------------ -------------------------

Parms Setup
-----------
*	Disabling the enforce plant selection switch, doesn't force the user to specify
	a plant in blanket order entry (13531).
	
Small Setups
------------
*	Users now has the ability to set up currencies in Monitor (13552). No further 
	functionality has been provided, just a setup.
*	Package Materials are arranged in the alphabetical order (13574).	
*	Operator passwords are displayed as asterisks in small setups (13565)

Part Master
-----------
*	Users now has the capability of deleting a Engineering Change level entry (13593).
*	Vendor notes column width has been increased to accomodate more characters (13581).
*	Userdefinable columns is restricted to only 25 characters from the data entry screens
	(13573).

Inventory (Administrative Module)
---------------------------------
*	Users have the ability to input cost when they are creating the inventory as it
	will be useful for importing data to accounting (13580).
	

Customers, Vendors & Destination Setup
--------------------------------------
*	Customer, vendor & destination (codes) accepts only alphnumeric charaters (13570).

	
Customer Service/Quotes
-----------------------
*	Users now has the ability to add the same part on the same quote with different 
	quantities, so that price breaks can be communicated (13175).
*	The error message while searching on customers has been resolved (13570).	


Order Entry
-----------
*	Users will now be able to edit the quantity on accum type based blanket orders (13588).


ASN Control Center
------------------
*	Correcting the errors in the control center, data is saved to the missing data lines 
	instead of just	the 1st line (13530).
*	The data refreshal problem has been resolved (13535).
	
	
Invoicing
---------
*	Edited invoice in monitor could be re-posted to accounting ( applicable only to 
	empower accounting) (13177).
*	Return vendor & outside process shippers are suppressed from the invoicing screen
	(13562).

Production Scheduling
---------------------
*	The 4th machine display problem has been resolved (13583).
*	Grid data can be saved to a file (13593)


Planning Board
--------------
*	The locking issue when planning board is opened has been resolved (13591)

	
Purchasing
----------
*	Tabbing through from field to field in PO printing is more sequential (13380).
*	Grid data can be saved to a file under PO scheduling grid (13593)

Inquiry Screens
---------------
*	Users now have the ability to save the filters in most of the inquiry screens. 
	Also retrieve them at a later point in time (11704).
	
Inventory Control
-----------------
*	Tabbing through from field to field in quality control screen has been resolved
	(13544).
*	Clicking on the Age button in Inventory Control displays the data in the date, time 
	order (13545).

Packing Line
------------
*	The lot field column in packing line is limited to 20 characters as the database
	allows only 20 characters (13561).

Shop Floor
----------
*	Users now has the ability to create new pallets in shop floor and also job complete
	on to the pallets (13431).
*	Multiple jobs on the same workorder could be closed once instead of closing each job 
	individually (13504).
*	Labor reporting screen displays the complete labor code (13563).	

Shipping Dock
-------------
*	The data display problem when a pallet is scanned on to a quick shipper, has been 
	resolved (13553).
*	Users have the ability to verify the scanning (a 2nd scanning process while loading
	on to the truck from the staging area). The system will indicate any discripencies
	(13506).
*	Problem with shipout routine updating normal orders has been resolved (13587).
	
	
PO Requisition
--------------
*	The inquiry listing now shows the requisitons without a vendor code in the header
	column (13546).	
*	Vendor code is made mandatory when they try to approve the requisition. Meaning the
	approver will have to specify a vendor code before approving. 


Standard Reports
----------------
*	Four more reports have been added to our standard reports library


Build 4.3.20011231
------------------

Customer Service
----------------
*	Refreshal problem in issues inquiry filter window has been fixed (13372)
*	The latest solution on any issue is shown in the solution field (13375)
*	Customers are listed in the alphabetical order (13378)
*	Ability to find ship history by shipper detail information as well as shipper 
	header information (12053, 12523) (ie toggling bet' detail and summary)
*	Both customer code & name, destination code & name are displayed in the
	treeview (12506)
*	User has the ability to print a contact and call log (13029)
*	RMA's now displays whether the rma is pending or closed (12023)
*	Error while converting a quote to a order, if enforce plant selections is enabled
	has been supressed (13529)
	
Executor
--------
*	Adding a task through the task manager now refreshes the list (13252)	
*	Scheduled tasks can be deleted through the task manager (13253)
*	The user has the ability to delete jobs (13253)

Global Shipping Schedular
-------------------------
*	Ability to put more than one part on the same shipper and customer po for the
	same destination (13466)

Inventory Control
-----------------
*	User now has the ability to break out objects to a pallet or a location (13488)
*	System prints a label when quality status is changed on the object (12064)
*	User has the ability to enable or disable defects reporting while doing a combo
	scan (13268)

Invoicing
---------
*	System now syncronizes shipper and invoice number if enabled on manual 
	invoices (13556)
*	System calculates the invoice totals correctly (13557)
*	User has the ability to put the required date range in invoice registry (13455)

Netout
------
*	Netout functionality has been enhanced 

Packing Line
------------
*	The error in packing line job completion has been suppressed (13555)

Purchasing
----------
*	Runtime error while creating relases through PO grid has been fixed (13353)
*	Close menu button under po inquiry screen allows the user to close all the 
	releases on a po where all the ordered quantity has been received (13271)
*	Non critical items like scac code, etc can be altered after fact, but not 
	freight type as it's part of the key on one of the tables (12636)
*			

Receiving
---------
*	System now supports receiving the original part back from an outside 
	process (13272, 13022)

Small Setups
------------
*	Filter button allows the user to filter for the required part type under price 
	list(ie finished, wip or raw). By default it brings up everything (12379)
	
Shipping
--------
*	Problem with buttons disappearing, when clicked on the pallet button has been 
	fixed (13373)
*	Quick shipper screen shows only quick shippers and not all shippers (13549)

Standard Labels
---------------
*	Standard lables now handle configurable parts (13455)

Standard Listings
-----------------
*	Listings are now available on part, customers and vendors

Standard Reports
----------------
*	Reports are now available (around 8)

Build to Stock Module
*	A new build to stock module is available (Please contact our customer support 
	representative for further details)
	
Database
--------
*	destination table has 10 additional custom columns (custom1-10). Accessable only 
	through isql (11933)



Build 4.0.2000410/4.0.2000814 Service Pack 4 (ie 4.2.4)
----------------------------- -------------------------

Vendor Setup
------------
*	Vendor status is controllable by the user ( i.e. to assign a Approved,
	On Hold or Closed status). (11841)


Part Vendor Profile
-------------------
*	Ability to search a vendor by typing a vendor code. (12926)


Purchasing
----------
*	Ability to edit the balance quantity instead of quantity required. (12619)
*	Ability to edit quantity and due date columns within the first screen without
	having to go to second screen on normal POs. (13257)
*	Visual Bill of Material (VBOM) is available from purchasing grid too on the
	clicked part. ( 13260)


Receiving
---------
*	Problem with part description being written to note field in the audit_trail
	has been fixed. (13351)


Order Entry
-----------
*	Duplicate sequence number problem in blanket orders has been resolved. (13451)
*	Ability to see totals all the time in normal order entry irrespective of the 
	number of detail lines. (13512)
*	Release number is now stored in shipper detail for drop ship orders. (13516)


Manual Invoices
---------------
*	Ability to edit certain header information on existing manual invoice. (12660)


Global Shipping Scheduler (GSS)
-------------------------------
*	The popup window in GSS has been re-sized to accomodate the large
	customer part. (13144)
*	Past Due (menu button) functionality has been fixed. (13180)
*	The datawindow error while adding/editing releases in quick data entry
	screen has been resolved. (13510)
*	Modifying release data in quick data entry screen doesn't remove 
	customer_part data. (13528)


Customer Service
----------------
*	Ability to sort the issues data by issue number. (13343)
*	Ability to switch to a new issue entry screen from within issue manager
	screen without going back to the list of issues screen. (13345)
*	Issue & solution boxes have been re-sized to accomodate more text. (13346)
*	A refresh button has been included in the customer service screen, to
	reflect the changes made to issues in the detail screen. (13374)
*	Appropriate messages will be displayed while trying to add contact which
	already exists in the database. (13376)
*	Tabbing problem while attaching a shipper detail to an RMA has been
	resolved. (13386)
*	Vertical Scroll bar is available in the ship history detailed screen. Also
	the correct part is highlighted upon going to the detailed screen. (13448)
*	Quote screen displays only finished parts in the drop down rather than 
	showing all types of parts. ( 13495)
*	Correct quote amount is displayed in list of quotes screen. (13496)
*	The default unit of measure is displayed on the part selected while adding
	a line item to the quotes. (13497)
*	The blue screen while adjusting the date range in the summary screen has
	been resolved. ( 13499)
*	Problem with deleting a contact has been resolved. (13536)	 


Inventory Control
-----------------
*	Single click on a part or a location which takes the user to the next screen
	has been disabled and it's available with double click. (13416)
*	Problem with quality control screen not writing operator code to object and 
	audit_trail has been resolved. ( 13524)
*	System now allows transfering of objects to a storage location. (13541)


Packing Line
------------
*	The correct customer part is associated in shipper_detail for configurable
	parts in pack line. (13456)
*	Shipping requirements window displays both customer part number and note
	columns. ( 13469)


Shipping Dock
-------------
*	Overstaging message is displayed only once upon entering the screen and 
	overstaging. 
*	Horizontal scroll bars are available for the pallet window. (13104)
*	Scroll bars are available for list of active shippers window in bill of
	lading control center. (13105)
*	Carriers in the BOL control center are in the sorted order. (13367)
*	Shipper and BOL notes are printed on the forms based on the customer
	destination/shipping switch setups. (13472)
*	Batch pick list functionality has been fixed. (13540)


Shop Floor
----------
*	Material unissuing/scrapping writes the correct audit_trail record. (13523)


Database Changes
----------------
*	Status column added to vendor table. (11841)
*	A new vendor_service_status table added to the db. (11841)
*	Definition changes to quotes view file (cs_quotes_vw). (13496)
*	Note column added to part_vendor table. (13502)
*	Admin table data is not lost by running the new service pack scripts. (13522)



Build 4.0.2000410/4.0.2000814 Service Pack 3 (ie 4.2.3)
----------------------------- -------------------------

Small Setups
------------
*	Changing a storage location to a machine and saving doesn't give any un-
	necessary messages (13377)
*	Enabling check lot control in parms setup forces shop floor module job
	completions to enter a lot number  (13411)
*	Enabling the limit locations for different type of inventory transactions
	in parms setup displays only those machines limited for that tyep of
	transaction (13412)
*	Enabling the printer setup check box in parms setup, brings up the printer
	setup screen when you try to print any forms (13434)

Customer and Vendor Setups
--------------------------
*	Address lines 4,5 and 6 have been restricted to 40 characters in both
	customer and vendor setups (13481)

Part Setup
----------
*	Default vendor column has not been removed, instead the system has been
	made flexiable enough to get the vendor if po is specified or get the
	list of POs for the specified vendor (13080)
*	A fast copy functionality of parts has been incorporated (13476)
*	The column headings have been corrected in Add price under part setup
	/purchasing screen (13059)
*	Part vendor profile (Purchasing Menu button) under part master allows the 
	user to enter notes on each of the part vendor relation which is used in 
	the standard po forms (13502)

Inventory Control (Admin)
-------------------------
*	System crash when object inquiry in parms is set to automatically retrieve
	parts upon entering the screen has been resolved (13479)
*	Object inquiry, deletion of a object and subsequently audit trail records is
	based on a switch in parameters (swtich is editable only through isql as of now)

Order Entry
-----------
*	System already has the ability to add multiple release quantites in
	order entry for the same day (12980)
*	Blanket order does populate the standard pack on selecting the part
	(13449)
*	ASN screen scrolling problem has been resolved (13453)

Customer Service
----------------
*	Ship history does display part number, po number and date shipped, but
	it's a matter of scrolling to the right to see these columns (12995)
*	Scrolling functionality using page up/down key has been incorporated
	in issues screen (13440)

Production Grid
---------------
*	Setting up an activity code in small setups, supresses the display of
	that activity in the grids (13409)

Purchasing
----------
*	The user does not have to tab back to the first column after entering
	data in the last field of the current line, the system automatically
	re-positions the cursor to the first column (13486)

PO Grid
-------
*	PO Netout Calc/Graph, daily buckets calculation has been fixed (13392)
*	The watchdog error while scheduling the demand from the last row in grids
	has been eliminated (13428)
*	The system does bring the respective default information when a new po
	is being created through the po grid (13494)

Receiving Dock
--------------
*	Bringing in material from an outside process using the out serial button,
	does allow the user to change the quantity (13153)
*	Receiving an out serial works the same way a regular po is received. It
	does populate price from po detail and standard cost from part standard
	(13300)
*	In receiving dock operator code will have to be entered to complete the
	transaction (13436)

Inventory Control
-----------------
*	Breakout packaging type does default to the package type associated to
	the part on serial (13423)
*	Problem with changing the status of a RMA receipt objects has been
	resolved ( 13484)

Shop Floor
----------
*	Material un-issue does create a different record instead of adjusting the
	original material issued record (13426, 13480)
*	Re-sequencing problem in shop floor has been resolved (13447)

Shipping Dock
-------------
*	Problem with closing a shipper when shipped out has been resolved (13477)
*	Users have the facility to see the box count and total quantity for a
	master pallet in the list of staged objects (13508)


Build 4.0.2000410/4.0.2000814 Service Pack 2 (ie 4.2.2)
----------------------------- -------------------------

Monitor
-------
*	The About option under Help displays the latest version no. which
	determines what service pack they are on currently.
*	System now displays the ODBC system DSNs too

Parm Setup
----------
*	Inventory Control Tab Page - Check Lot number column is
	editable (13411)
*	Onhand from Part online or objects under COP tab page has been
	removed from the sytem (13442)
*	Consolidate MPS option under COP tab page has been removed from
	the system (13443)
*	Time Horizions under COP tab page has been removed from the
	system (13444)
*	Vertical and Horizontal scroll bars are available when the window is
	not maximized (13415)


Small Setups
------------
*	Vertical and Horizontal scroll bars are available on all the small setup
	tab pages (13420)


Parts Setup
-----------
*	ESS is not stored as the operator when engineering change notice entry
	is made (13099)
*	SQLSTATE S0022 error while searching parts by class or type has been
	eliminated (13417)


Sales Orders
------------
*	Terms field cannot be edited after the sales order is saved in both normal
	and blanket orders. (13055)
*	The closed orders are filtered off of the inquiry screen


Outside Process
---------------
*	Reconciling an outserial from Office inventory/ outside process screen will
	show the correct values for cum received and vendor loss quantity. (13462)


Customer Service
----------------
*	The date range is editable at the customer level. Most of the items in the
	customer service use this date range for filtering the records from their
	respective tables. (13402)
*	Sales orders shows both blanket and normal orders in the list
*	Ship History, list of objects shipped for each shipper shows the lot number
	column (13009)
*	Ship history, now displays bol# column (13014)
*	Original shipper column is included in RMA screen (13015)


ASN Generator
-------------
*	System doesn't lock up when trying to edit the from date under test ASN's
	screen


Invoicing
---------
*	Duplicate lines are not created while editing RMA invoices (13406)


Purchase Orders
---------------
*	Drop Shipment Processor displays multiple lines (13405)
*	Grids are refreshed after creating po releases by dragging the demand and
	dropping it on a vendor. But when in po creating & adding releases manually,
	the user still needs to hit the re-calc button to refresh the grids. (13397)
*	Users have the option of seeing all the POs for that specific vendor or only
	POs pertaining to the plant from the grid. (13425)
*	Unit conversion is reflected in the release creation screen through grids.(13429)
*	Freight type, fob, ship via columns are populated when the vendor is selected
	while creating a po (13274)
*	Plant code cannot be Null error message while saving a po header, even though
	a plant code is specified is eliminated (13419,13457)


Planning Board
--------------
*	Users have the capability to display work order number or part on the task in
	the planning board (13408)
*	Users will no longer be able to edit the cycle time and parts per hour in
	machine grids job properties process tab page (13249)


Receiving Dock
--------------
*	Po number is now written back into the object, when you receive object(s) back
	into inventory from your customer via RMA (13400) [applicable for purchased parts]
*	Show all check box, shows all the objects received against the current po or
	nothing (13217)

Inventory Control
-----------------
*	Comboscan doesn't loose the job completed entry, when the user cancels out of
	defects entry (13458)
*	Undoing a comboscan reverts back the defects reported against the comboscanned
	serial (13459)

Shop Floor
----------
*	Schedule button, shows all the parts, it's description and ecn on all the jobs in
	the queue. (13438)
*	Users will now be able to scan objects without any problem
*	The clicked row is retained after a material issue is done, so that the users
	could continue issuing materials for the same part without having to scroll (13465)


Shipping Dock
-------------
*	Data truncated error in Shipping Dock has been supressed (13398)
*	The search function has been enhanced, so that the user doesn't need to
	put quotes for string data while searching for string columns (eg customer,
	destination etc) (13401)
*	Undoing a pallet (ie deleting) a pallet does create a audit_trail record (13414)
*	Cancel button cancel's the operation while creating the pallet, instead of
	creating it (13413)

Standard forms & labels
-----------------------
*	Monitor standard forms and labels are available for the users


Build 4.0.2000410/4.0.2000814 Service Pack 1 (ie 4.2.1)
----------------------------- -------------------------

Customer Service
----------------
*	The AddDoc & AddFile menu buttons are disable while creating a new
	issue until the issue is saved. (13318)
*	Supressed the Monitor Watch Dog error while deleting a quote detail
	line item
*	Destination screen brings up the correct values now. (12991)


Invoice Register
----------------
*	Scroll Bars are available for the Account Code window. (13112)


Purchase Orders
---------------
*	Data truncation Error in po inquiry(blanket/normal)/po processor screen
	has been eleminated
*	In blanket or normal orders creation, ship_to_destination is not
	automatically populated with the plant code, unless ship to is blank. If
	something has been selected by the user it stays selected as is. (12910)


Receiving Dock
--------------
*	History is updated correctly on reversal of receipts. (13219)


Sales Orders
----------------
*	Customer Price discounts are calculated correctly in Normal order screen


Customer Category Pricing
-------------------------
*	The user need to re-select whether All/Part/Category to refresh the screen
	to see the category setup changes


Promotion
---------
*	Part, Customer and Category are made mandetory in promotion screen. It's
	just an	extension of category pricing
*	The user has the functionality to view all his promotions


Shipping Dock
-------------
*	The cancel button while doing a batchpicklist in shipping dock, does not
	print the document now. (13069)


Parameters
----------
*	Exiting the screen after modifying the data in parameter setup will prompt
	the user to save the data before exiting


Shop Floor
----------
*	The problem with unable to create audit trail record with material issuing
	has been fixed
*	The data truncated error while trying to do a material issue has been
	supressed.


Inventory Control
-----------------
*	The problem with locations not bringing up parts has been fixed.
*	The data truncated error while transfering the object to a different location
	has been supressed.
