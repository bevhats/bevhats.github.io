CREATE OR REPLACE PACKAGE LEVEL_1_FORECAST_UTIL_API IS

module_  CONSTANT VARCHAR2(25) := 'MASSCH';
lu_name_ CONSTANT VARCHAR2(25) := 'Level1ForecastUtil';
lu_type_ CONSTANT VARCHAR2(25) := 'Utility';

-----------------------------------------------------------------------------
-------------------- PUBLIC DECLARATIONS ------------------------------------
-----------------------------------------------------------------------------

TYPE Supply_Record IS RECORD
      ( ms_date      DATE,
        line_no      NUMBER,
        supply_qty   NUMBER );

TYPE Supply_Collection IS TABLE OF Supply_Record INDEX BY PLS_INTEGER;


-----------------------------------------------------------------------------
-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
-----------------------------------------------------------------------------
-- Shipment_Update
--   This method makes an adjustment to Forecast(s) and Consumed Forecasts
--   between the beginning of the existing horizon (including past due) and
--   the DTF, based on Actual Demand that is shipped.
--
-- Shipment_Update
--   This method makes an adjustment to Forecast(s) and Consumed Forecasts
--   between the beginning of the existing horizon (including past due) and
--   the DTF, based on Actual Demand that is shipped.
--
-- Control_Consumption
--   Initiates forecast consumption or unconsumption for a MASSCH part/contract
--   when a customer order line is created/updated with status Released.
--   Additional parameters are a new and old qty, and a new and old due date.
--   The old qty is null in case of a new order line.
--
-- Consume_Forecast
--   Initiates forecast consumption for a part/contract when a customer order
--   line is created/updated with status Released. Additional parameters are
--   a new and old qty, and a due date. The old qty is null in case of a new order line.
--   Is also called during the MS batch process to recalculate
--   Forecast Consumption over the entire horizon of the part.
--
-- Consume_Supply
--   This method is called online when booking a customer order,
--   and also during the MS level 1 batch process.
--
-- Update_Consumption
--
-- Unconsume_Forecast
--   This method is called when a customer order for a MASSCH part is
--   either cancelled or has its qty decreased. MASSCH forecast is unconsumed
--   for the cancelled qty or the decreased qty.
--
-- Unconsume_Supply
--   This method is called online when reducing order line qtys,
--   and when cancelling order qtys.
--
-- Update_Family_Info
--   Update level 0 family info if this part belongs to a level 0 family.
--
-- Get_Sum_Of_Forecast
--   Method to get the sum of Forecast Level 0 and Forecast Level 1.
--
-- Get_Last_Forecast_Date
--   Method to get the last forecast date (MsDate).
--
-- Get_Sum_Forecast_Lev0
--   Get the total sum of Forecast Level 0.
--
-- Get_Sum_Forecast_Lev1
--   Get the total sum of Forecast Level 1.
--
-- Get_Sum_Master_Sched_Rcpt
--   Get the total sum of MS Receipt.
--
-- Copy_Forecast
--   Copy Forecast Level 0 and Forecast Level 1 from a source MS Set
--   to a target MS Set.
--
-- Copy_Entire_Master_Schedule
--   Clone MS data from given ms set to a new ms set
--   procedure first remove the data in target ms set
--   target MS set should not be 1
--
-- Add_Forecast
--   Add Forecasts Level 0 and Forecast Level 1 from source MS Sets(s)
--   to a target MS Set.
--
-- Reset_Forecast
--   Reset Forecast Level 0 and Forecast Level 1 to zero.
--
-- Remove_Master_Schedule
--   Used to remove all data connected to a MS set
--
-- Get_Sum_Fcst_Lev0
--   Gets sum of level 0 forecasts for a specific MS set between two dates
--
-- Get_Sum_Fcst_Lev1
--   Gets sum of level 1 forecasts for a specific MS set between two dates
--
-- Get_Sum_Con_Fcst
--   Gets sum of consumed forecasts for a specific MS set between two dates
--
-- Get_Sum_Uncon_Fcst
--   Gets sum of unconsumed forecasts for a specific MS set between two dates
--
-- Get_Sum_Act_Dem
--   Gets sum of actual demands for a specific MS set between two dates
--
-- Get_Sum_Plan_Dem
--   Gets sum of planned demands for a specific MS set between two dates
--
-- Get_Sum_Supply
--   Gets sum of supply for a specific MS set between two dates
--
-- Get_Sum_Con_Sup
--   Gets sum of consumed supply for a specific MS set between two dates
--
-- Get_Sum_Firm_Ord
--   Gets sum of firmed orders for a specific MS set between two dates
--
-- Get_Sum_Rel_Ord
--   Gets sum of released orders for a specific MS set between two dates
--
-- Get_Sum_Sch_Ord
--   Gets sum of scheduled orders for a specific MS set between two dates
--
-- Get_Sum_Ms_Rcpt
--   Gets sum of MS receipts for a specific MS set between two dates
--
-- Get_Sum_Atp
--   Gets sum of ATP for a specific MS set between two dates
--
-- Get_Sum_Avail_To_Prom
--   Gets sum of ATP for a specific MS set between two dates
--
-- Get_Sum_Mtr_Demand
--   Gets sum of MTR demand for a specific MS set between a range of dates.
--
-- Get_Sum_Mtr_Supply
--   Gets sum of MTR supply for a specific MS set between a range of dates.
--
-- Is_Import_Running
--   This method is a function that returns a number indicating whether the
--   calling method can run (0) or not run (1) the import of demand planning
--   forecasts for Master Scheduling.
--
-- Validate_Params
--   Validate method for Import Forecast batch schedule.
-----------------------------------------------------------------------------

PROCEDURE Shipment_Update (
   contract_         IN VARCHAR2,
   part_no_          IN VARCHAR2,
   qty_shipped_      IN NUMBER,
   planned_due_date_ IN DATE DEFAULT NULL );

PROCEDURE Shipment_Update (
   contract_         IN VARCHAR2,
   part_no_          IN VARCHAR2,
   activity_seq_     IN NUMBER,
   qty_shipped_      IN NUMBER,
   planned_due_date_ IN DATE );

PROCEDURE Control_Consumption (
   result_code_                 OUT VARCHAR2,
   available_qty_               OUT NUMBER,
   earliest_available_date_     OUT DATE,
   contract_                    IN VARCHAR2,
   part_no_                     IN VARCHAR2,
   new_demand_qty_              IN NUMBER,
   old_demand_qty_              IN NUMBER,
   new_due_date_                IN DATE,
   old_due_date_                IN DATE,
   source_type_                 IN VARCHAR2,
   order_line_cancellation_     IN BOOLEAN );

PROCEDURE Consume_Forecast (
   contract_                 IN VARCHAR2,
   part_no_                  IN VARCHAR2,
   png_                      IN VARCHAR2,
   ms_set_                   IN NUMBER,
   total_demand_activity_    IN NUMBER,
   default_supply_activity_  IN NUMBER,
   order_line_new_qty_       IN NUMBER,
   order_line_old_qty_       IN NUMBER,
   order_line_due_date_      IN DATE,
   source_type_              IN VARCHAR2,
   promise_method_db_        IN VARCHAR2,
   forecast_consumption_wnd_ IN NUMBER,
   fwd_forecast_consumption_ IN NUMBER,
   calendar_id_              IN VARCHAR2,
   consuming_fcst_online_    IN BOOLEAN);

PROCEDURE Consume_Supply (
   contract_                IN VARCHAR2,
   part_no_                 IN VARCHAR2,
   png_                     IN VARCHAR2,
   ms_set_                  IN NUMBER,
   activity_seq_            IN NUMBER,
   order_line_new_qty_      IN NUMBER,
   order_line_old_qty_      IN NUMBER,
   order_line_due_date_     IN DATE,
   promise_method_db_       IN VARCHAR2,
   calendar_id_             IN VARCHAR2,
   consuming_fcst_online_   IN BOOLEAN,
   source_type_             IN VARCHAR2,
   order_line_cancellation_ IN BOOLEAN);

PROCEDURE Update_Consumption (
   contract_                 IN VARCHAR2,
   part_no_                  IN VARCHAR2,
   new_demand_quantity_      IN NUMBER,
   old_demand_quantity_      IN NUMBER,
   new_due_date_             IN DATE,
   old_due_date_             IN DATE);

PROCEDURE Unconsume_Forecast (
   contract_                  IN VARCHAR2,
   part_no_                   IN VARCHAR2,
   png_                       IN VARCHAR2,
   ms_set_                    IN NUMBER,
   ms_receipt_activity_seq_   IN NUMBER,
   new_demand_qty_            IN NUMBER,
   old_demand_qty_            IN NUMBER,
   new_due_date_              IN DATE,
   old_due_date_              IN DATE,
   source_type_               IN VARCHAR2,
   promise_method_db_         IN VARCHAR2,
   calendar_id_               IN VARCHAR2,
   forecast_consumption_wnd_  IN NUMBER,
   fwd_forecast_consumption_  IN NUMBER );

PROCEDURE Unconsume_Supply (
   contract_                IN VARCHAR2,
   part_no_                 IN VARCHAR2,
   png_                     IN VARCHAR2,
   ms_set_                  IN NUMBER,
   new_demand_qty_          IN NUMBER,
   old_demand_qty_          IN NUMBER,
   new_due_date_            IN DATE,
   old_due_date_            IN DATE,
   consuming_fcst_online_   IN BOOLEAN,
   source_type_             IN VARCHAR2,
   promise_method_db_       IN VARCHAR2,
   calendar_id_             IN VARCHAR2,
   order_line_cancellation_ IN BOOLEAN );

PROCEDURE Update_Family_Info (
   contract_   IN VARCHAR2,
   part_no_    IN VARCHAR2,
   png_        IN VARCHAR2,
   ms_set_     IN NUMBER );

--@PoReadOnly(Get_Sum_Of_Forecast)
FUNCTION Get_Sum_Of_Forecast (
   contract_  IN VARCHAR2,
   part_no_   IN VARCHAR2,
   png_       IN VARCHAR2,
   ms_set_    IN NUMBER,
   from_date_ IN DATE,
   to_date_   IN DATE ) RETURN NUMBER;

--@PoReadOnly(Get_Last_Forecast_Date)
FUNCTION Get_Last_Forecast_Date (
   contract_  IN VARCHAR2,
   part_no_   IN VARCHAR2,
   png_       IN VARCHAR2,
   ms_set_    IN NUMBER,
   from_date_ IN DATE,
   to_date_   IN DATE ) RETURN DATE;

--@PoReadOnly(Get_Sum_Forecast_Lev0)
FUNCTION Get_Sum_Forecast_Lev0 (
   contract_  IN VARCHAR2,
   part_no_   IN VARCHAR2,
   png_       IN VARCHAR2,
   ms_set_    IN NUMBER ) RETURN NUMBER;

--@PoReadOnly(Get_Sum_Forecast_Lev1)
FUNCTION Get_Sum_Forecast_Lev1 (
   contract_  IN VARCHAR2,
   part_no_   IN VARCHAR2,
   png_       IN VARCHAR2,
   ms_set_    IN NUMBER ) RETURN NUMBER;

--@PoReadOnly(Get_Sum_Master_Sched_Rcpt)
FUNCTION Get_Sum_Master_Sched_Rcpt (
   contract_  IN VARCHAR2,
   part_no_   IN VARCHAR2,
   png_       IN VARCHAR2,
   ms_set_    IN NUMBER ) RETURN NUMBER;

PROCEDURE Copy_Forecast (
   contract_      IN VARCHAR2,
   part_no_       IN VARCHAR2,
   png_           IN VARCHAR2,
   from_ms_set_   IN NUMBER,
   to_ms_set_     IN NUMBER,
   start_date_    IN DATE,
   copy_lev0_     IN NUMBER,
   copy_lev1_     IN NUMBER );

PROCEDURE Copy_Entire_Master_Schedule(
   contract_      IN VARCHAR2,
   from_ms_set_   IN NUMBER,
   to_ms_set_     IN NUMBER,
   part_no_       IN VARCHAR2,
   png_           IN VARCHAR2);

PROCEDURE Add_Forecast (
   contract_      IN VARCHAR2,
   part_no_       IN VARCHAR2,
   png_           IN VARCHAR2,
   from_ms_set_   IN NUMBER,
   to_ms_set_     IN NUMBER,
   start_date_    IN DATE,
   copy_lev0_     IN NUMBER,
   copy_lev1_     IN NUMBER );

PROCEDURE Reset_Forecast (
   contract_     IN VARCHAR2,
   part_no_      IN VARCHAR2,
   png_          IN VARCHAR2,
   to_ms_set_    IN NUMBER,
   start_date_   IN DATE,
   copy_lev0_    IN NUMBER,
   copy_lev1_    IN NUMBER );

PROCEDURE Remove_Master_Schedule (
   contract_   IN VARCHAR2,   
   ms_set_     IN NUMBER);

--@PoReadOnly(Get_Sum_Fcst_Lev0)
FUNCTION Get_Sum_Fcst_Lev0 (
   contract_        IN VARCHAR2,
   part_no_         IN VARCHAR2,
   png_             IN VARCHAR2,
   ms_set_          IN NUMBER,
   begin_date_      IN DATE,
   end_date_        IN DATE ) RETURN NUMBER;

--@PoReadOnly(Get_Sum_Fcst_Lev1)
FUNCTION Get_Sum_Fcst_Lev1 (
   contract_        IN VARCHAR2,
   part_no_         IN VARCHAR2,
   png_             IN VARCHAR2,
   ms_set_          IN NUMBER,
   begin_date_      IN DATE,
   end_date_        IN DATE ) RETURN NUMBER;

--@PoReadOnly(Get_Sum_Con_Fcst)
FUNCTION Get_Sum_Con_Fcst (
   contract_        IN VARCHAR2,
   part_no_         IN VARCHAR2,
   png_             IN VARCHAR2,
   ms_set_          IN NUMBER,
   begin_date_      IN DATE,
   end_date_        IN DATE ) RETURN NUMBER;

--@PoReadOnly(Get_Sum_Uncon_Fcst)
FUNCTION Get_Sum_Uncon_Fcst (
   contract_        IN VARCHAR2,
   part_no_         IN VARCHAR2,
   png_             IN VARCHAR2,
   ms_set_          IN NUMBER,
   begin_date_      IN DATE,
   end_date_        IN DATE ) RETURN NUMBER;

--@PoReadOnly(Get_Sum_Act_Dem)
FUNCTION Get_Sum_Act_Dem (
   contract_        IN VARCHAR2,
   part_no_         IN VARCHAR2,
   png_             IN VARCHAR2,
   ms_set_          IN NUMBER,
   begin_date_      IN DATE,
   end_date_        IN DATE ) RETURN NUMBER;

--@PoReadOnly(Get_Sum_Plan_Dem)
FUNCTION Get_Sum_Plan_Dem (
   contract_        IN VARCHAR2,
   part_no_         IN VARCHAR2,
   png_             IN VARCHAR2,
   ms_set_          IN NUMBER,
   begin_date_      IN DATE,
   end_date_        IN DATE ) RETURN NUMBER;

--@PoReadOnly(Get_Sum_Supply)
FUNCTION Get_Sum_Supply (
   contract_        IN VARCHAR2,
   part_no_         IN VARCHAR2,
   png_             IN VARCHAR2,
   ms_set_          IN NUMBER,
   begin_date_      IN DATE,
   end_date_        IN DATE ) RETURN NUMBER;

--@PoReadOnly(Get_Sum_Con_Sup)
FUNCTION Get_Sum_Con_Sup (
   contract_        IN VARCHAR2,
   part_no_         IN VARCHAR2,
   png_             IN VARCHAR2,
   ms_set_          IN NUMBER,
   begin_date_      IN DATE,
   end_date_        IN DATE ) RETURN NUMBER;

--@PoReadOnly(Get_Sum_Firm_Ord)
FUNCTION Get_Sum_Firm_Ord (
   contract_        IN VARCHAR2,
   part_no_         IN VARCHAR2,
   png_             IN VARCHAR2,
   ms_set_          IN NUMBER,
   begin_date_      IN DATE,
   end_date_        IN DATE ) RETURN NUMBER;

--@PoReadOnly(Get_Sum_Rel_Ord)
FUNCTION Get_Sum_Rel_Ord (
   contract_        IN VARCHAR2,
   part_no_         IN VARCHAR2,
   png_             IN VARCHAR2,
   ms_set_          IN NUMBER,
   begin_date_      IN DATE,
   end_date_        IN DATE ) RETURN NUMBER;

--@PoReadOnly(Get_Sum_Sch_Ord)
FUNCTION Get_Sum_Sch_Ord (
   contract_        IN VARCHAR2,
   part_no_         IN VARCHAR2,
   png_             IN VARCHAR2,
   ms_set_          IN NUMBER,
   begin_date_      IN DATE,
   end_date_        IN DATE ) RETURN NUMBER;

--@PoReadOnly(Get_Sum_Ms_Rcpt)
FUNCTION Get_Sum_Ms_Rcpt (
   contract_        IN VARCHAR2,
   part_no_         IN VARCHAR2,
   png_             IN VARCHAR2,
   ms_set_          IN NUMBER,
   begin_date_      IN DATE,
   end_date_        IN DATE ) RETURN NUMBER;

--@PoReadOnly(Get_Sum_Atp)
FUNCTION Get_Sum_Atp (
   contract_        IN VARCHAR2,
   part_no_         IN VARCHAR2,
   png_             IN VARCHAR2,
   ms_set_          IN NUMBER,
   begin_date_      IN DATE,
   end_date_        IN DATE ) RETURN NUMBER;

--@PoReadOnly(Get_Sum_Avail_To_Prom)
FUNCTION Get_Sum_Avail_To_Prom (
   contract_        IN VARCHAR2,
   part_no_         IN VARCHAR2,
   png_             IN VARCHAR2,
   ms_set_          IN NUMBER,
   begin_date_      IN DATE,
   end_date_        IN DATE ) RETURN NUMBER;

--@PoReadOnly(Get_Sum_Mtr_Demand)
FUNCTION Get_Sum_Mtr_Demand (
   contract_   IN VARCHAR2,
   part_no_    IN VARCHAR2,
   png_        IN VARCHAR2,
   ms_set_     IN NUMBER,
   begin_date_ IN DATE,
   end_date_   IN DATE ) RETURN NUMBER;

--@PoReadOnly(Get_Sum_Mtr_Supply)
FUNCTION Get_Sum_Mtr_Supply (
   contract_   IN VARCHAR2,
   part_no_    IN VARCHAR2,
   png_        IN VARCHAR2,
   ms_set_     IN NUMBER,
   begin_date_ IN DATE,
   end_date_   IN DATE ) RETURN NUMBER;

FUNCTION Is_Import_Running (
   contract_ IN VARCHAR2,
   part_no_ IN VARCHAR2,
   ms_set_ IN VARCHAR2 ) RETURN NUMBER;

PROCEDURE Validate_Params (
   message_ IN VARCHAR2 );

-----------------------------------------------------------------------------
-------------------- LU SPECIFIC PROTECTED METHODS --------------------------
-----------------------------------------------------------------------------
-- Initiate_
--   This is the umbrella method when calculating level 1 for a specific site,
--   part and ms_set. It contains a lot of method calls for managing the level 1
--   calculation. In the end it calls the Calculate_Ms_Receipt_ method wich
--   performs the netting logic within the level 1 calculation.
--
-- Calculate_Ms_Receipt_
--   This method is responsible for the netting calculation in level 1.
--   It also schedules the proposed MasterSchedRcpt qty
--
-- Calculate_Proj_Avail_
--   Calculates projected balance (calculated balance).
-----------------------------------------------------------------------------

PROCEDURE Initiate_ (
   contract_                      IN VARCHAR2,
   part_no_                       IN VARCHAR2,
   png_                           IN VARCHAR2,
   ms_set_                        IN NUMBER,
   run_date_                      IN DATE,
   demand_tf_                     IN DATE,
   planning_tf_                   IN DATE,
   qty_onhand_                    IN NUMBER,
   roll_flag_db_                  IN VARCHAR2,
   shop_order_proposal_flag_db_   IN VARCHAR2,
   create_fixed_ms_receipt_db_    IN VARCHAR2,
   split_manuf_acquired_          IN VARCHAR2,
   is_part_internally_sourced_    IN VARCHAR2,
   order_proposal_release_db_     IN VARCHAR2,
   manuf_supply_type_             IN VARCHAR2,
   acquired_supply_type_          IN VARCHAR2,
   prev_run_date_                 IN DATE,
   pur_lu_req_exists_             IN BOOLEAN,
   so_lu_prop_exists_             IN BOOLEAN,
   calendar_id_                   IN VARCHAR2,
   min_date_                      IN DATE,
   max_date_                      IN DATE,
   start_crp_calc_                IN BOOLEAN );

PROCEDURE Calculate_Ms_Receipt_ (
   contract_                      IN VARCHAR2,
   part_no_                       IN VARCHAR2,
   png_                           IN VARCHAR2,
   ms_set_                        IN NUMBER,
   ms_date_                       IN DATE,
   inventory_part_plan_rec_       IN Inventory_Part_Planning_API.Public_Rec,
   qty_onhand_                    IN NUMBER,
   demand_tf_                     IN DATE,
   planning_tf_                   IN DATE,
   roll_flag_db_                  IN VARCHAR2,
   lead_time_code_db_             IN VARCHAR2,
   shop_order_proposal_flag_db_   IN VARCHAR2,
   create_fixed_ms_receipt_db_    IN VARCHAR2,
   split_manuf_acquired_          IN VARCHAR2,
   is_part_internally_sourced_    IN VARCHAR2,
   order_proposal_release_db_     IN VARCHAR2,
   manuf_supply_type_             IN VARCHAR2,
   acquired_supply_type_          IN VARCHAR2,
   pur_lu_req_exists_             IN BOOLEAN,
   calendar_id_                   IN VARCHAR2,
   unit_meas_                     IN VARCHAR2,
   stock_management_              IN VARCHAR2,
   min_date_                      IN DATE,
   max_date_                      IN DATE,
   start_crp_calc_                IN BOOLEAN );

PROCEDURE Calculate_Proj_Avail_ (
   contract_              IN VARCHAR2,
   part_no_               IN VARCHAR2,
   png_                   IN VARCHAR2,
   ms_set_                IN NUMBER,
   qty_onhand_            IN NUMBER,
   demand_tf_date_        IN DATE,
   planning_tf_date_      IN DATE,
   lead_time_code_db_     IN VARCHAR2 );

-----------------------------------------------------------------------------
-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------
-----------------------------------------------------------------------------
-- Massch_Atp_Check__
--
-- Recalc_Consumed_Fcst__
--   Initializes and recalculates consumed forecast during MS batch process,
--   as well as online unconsumption of forecasts during order changes.
--
-- Recalc_Consumed_Supply__
--   Initializes and recalculates consumed supply during MS batch process,
--   as well as online unconsumption of supply during order changes.
--
-- Rollout_Unconsumed_Fcst__
--   Rolls out unconsumed forecast to outside DTF during MS batch process.
--
-- Recalc_Level1_Supply__
--   Initializes and recalculates level_1_forecast.supply column during
--   MS batch process, as well as during online consumption of supply
--   during order changes.
--
-- Remove_Shop_Proposal__
--   Removes Shop Order requisition(s) and
--   sets the Supply_Order_Detail status if necessary.
--
-- Generate_Shop_Proposal__
--   Generates Shop Order requisitions based on MS receipt status.
--
-- Remove_Pur_Req__
--   Removes Purchase Order requisition(s)
--   and sets the Supply_Order_Detail status if necessary.
--
-- Generate_Pur_Req__
--   Generates Purchase Order requisitions, based on MS receipt status.
--
-- Remove_Production_Schedules__
--   Deletes production schedules at beginning of MS batch run for repetitive
--   manufactured parts, deleting non-firm schedules only outside the firm
--   horizon for the horizon id of the manufacturing cell.
--   Sets the Supply_Order_Detail status if necessary.
--
-- Gen_Production_Schedules__
--   Generates production schedules as part of MS batch process for repetitively
--   manufactured parts, based on MS receipt status.
--
-- Remove_Do__
--   Removes Distribution Order(s) and
--   sets the Supply_Order_Detail status if necessary.
--
-- Generate_Do__
--   Generates Distribution Orders, based on MS receipt status.
--
-- Schedule_Import_Forecast__
--   Private method called by the public method of the same name that carries
--   out the actual scheduling of the forecast import batch job.
-----------------------------------------------------------------------------

PROCEDURE Massch_Atp_Check__ (
   result_code_               OUT VARCHAR2,
   available_qty_             OUT NUMBER,
   earliest_available_date_   OUT DATE,
   contract_                  IN VARCHAR2,
   part_no_                   IN VARCHAR2,
   png_                       IN VARCHAR2,
   activity_seq_              IN NUMBER,
   order_line_qty_            IN NUMBER,
   order_line_due_date_       IN DATE,
   promise_method_db_         IN VARCHAR2,
   calendar_id_               IN VARCHAR2,
   ptf_date_                  IN DATE );

PROCEDURE Recalc_Consumed_Fcst__ (
   contract_                 IN VARCHAR2,
   part_no_                  IN VARCHAR2,
   png_                      IN VARCHAR2,
   ms_set_                   IN NUMBER,
   ms_receipt_activity_seq_  IN NUMBER,
   consuming_fcst_online_    IN BOOLEAN,
   source_type_              IN VARCHAR2,
   promise_method_db_        IN VARCHAR2,
   calendar_id_              IN VARCHAR2,
   forecast_consumption_wnd_ IN NUMBER,
   fwd_forecast_consumption_ IN NUMBER );

PROCEDURE Recalc_Consumed_Supply__ (
   contract_                IN VARCHAR2,
   part_no_                 IN VARCHAR2,
   png_                     IN VARCHAR2,
   ms_set_                  IN NUMBER,
   consuming_fcst_online_   IN BOOLEAN,
   source_type_             IN VARCHAR2,
   promise_method_db_       IN VARCHAR2,
   calendar_id_             IN VARCHAR2,
   order_line_cancellation_ IN BOOLEAN );

PROCEDURE Rollout_Unconsumed_Fcst__ (
   contract_                IN VARCHAR2,
   part_no_                 IN VARCHAR2,
   png_                     IN VARCHAR2,
   ms_set_                  IN NUMBER,
   ms_receipt_activity_seq_ IN NUMBER,
   dtf_date_                IN DATE,
   calendar_id_             IN VARCHAR2,
   max_unconsumed_fcst_     IN NUMBER,
   roll_by_percentage_      IN NUMBER,
   roll_window_             IN NUMBER );

PROCEDURE Recalc_Level1_Supply__ (
   contract_      IN VARCHAR2,
   part_no_       IN VARCHAR2,
   png_           IN VARCHAR2,
   ms_set_        IN NUMBER,
   run_date_      IN DATE,
   dtf_date_      IN DATE,
   ptf_date_      IN DATE,
   qty_onhand_    IN NUMBER);

PROCEDURE Remove_Shop_Proposal__ (
   contract_             IN VARCHAR2,
   part_no_              IN VARCHAR2,
   png_                  IN VARCHAR2,
   period_1_             IN DATE,
   period_2_             IN DATE,
   pmps_run_seq_         IN NUMBER,
   activity_seq_         IN NUMBER );

PROCEDURE Generate_Shop_Proposal__ (
   contract_                IN VARCHAR2,
   part_no_                 IN VARCHAR2,
   png_                     IN VARCHAR2,
   ms_receipt_activity_seq_ IN NUMBER,
   split_manuf_acquired_    IN VARCHAR2,
   period_1_                IN DATE,
   period_2_                IN DATE,
   calendar_id_             IN VARCHAR2,
   start_crp_calc_          IN BOOLEAN,
   do_supply_arr_           IN Supply_Collection,
   inside_ptf_              IN BOOLEAN DEFAULT TRUE );

PROCEDURE Remove_Pur_Req__ (
   contract_             IN VARCHAR2,
   part_no_              IN VARCHAR2,
   png_                  IN VARCHAR2,
   demand_tf_            IN DATE,
   planning_tf_          IN DATE,
   pmps_run_seq_         IN NUMBER,
   activity_seq_         IN NUMBER );

PROCEDURE Generate_Pur_Req__ (
   contract_                   IN VARCHAR2,
   part_no_                    IN VARCHAR2,
   png_                        IN VARCHAR2,
   ms_receipt_activity_seq_    IN NUMBER,
   unit_meas_                  IN VARCHAR2,
   demand_tf_                  IN DATE,
   planning_tf_                IN DATE,
   inside_ptf_                 IN BOOLEAN DEFAULT TRUE );

PROCEDURE Remove_Production_Schedules__ (
   contract_             IN VARCHAR2,
   part_no_              IN VARCHAR2,
   png_                  IN VARCHAR2,
   demand_tf_            IN DATE,
   planning_tf_          IN DATE );

PROCEDURE Gen_Production_Schedules__ (
   contract_             IN VARCHAR2,
   part_no_              IN VARCHAR2,
   png_                  IN VARCHAR2,
   ms_set_               IN NUMBER,
   split_manuf_acquired_ IN VARCHAR2,
   demand_tf_            IN DATE,
   planning_tf_          IN DATE,
   run_date_             IN DATE,
   calendar_id_          IN VARCHAR2,
   start_crp_calc_       IN BOOLEAN,
   do_supply_arr_        IN Supply_Collection );

PROCEDURE Remove_Do__ (
   contract_             IN VARCHAR2,
   part_no_              IN VARCHAR2,
   png_                  IN VARCHAR2,
   demand_tf_            IN DATE,
   planning_tf_          IN DATE );

PROCEDURE Generate_Do__ (
   applied_dis_ord_date_    OUT    DATE,
   adjusted_increment_qty_  IN OUT NOCOPY NUMBER,
   do_supply_arr_           IN OUT NOCOPY Supply_Collection,
   contract_                IN     VARCHAR2,
   part_no_                 IN     VARCHAR2,
   png_                     IN     VARCHAR2,
   ms_set_                  IN     NUMBER,
   split_manuf_acquired_    IN     VARCHAR2,
   demand_tf_               IN     DATE,
   planning_tf_             IN     DATE,
   calendar_id_             IN     VARCHAR2 );

PROCEDURE Schedule_Import_Forecast__ (
   attrib_ IN VARCHAR2 );

-----------------------------------------------------------------------------
-------------------- FOUNDATION1 METHODS ------------------------------------
-----------------------------------------------------------------------------
-- Init
--   Framework method that initializes this package.
-----------------------------------------------------------------------------

--@PoReadOnly(Init)
PROCEDURE Init;

END LEVEL_1_FORECAST_UTIL_API;
/
CREATE OR REPLACE PACKAGE BODY LEVEL_1_FORECAST_UTIL_API IS

-----------------------------------------------------------------------------
-------------------- PRIVATE DECLARATIONS -----------------------------------
-----------------------------------------------------------------------------

sysgen_yes_                 CONSTANT VARCHAR2(1) := Sysgen_API.DB_PROPOSED;

sysgen_no_                  CONSTANT VARCHAR2(1) := Sysgen_API.DB_FIXED;

alternative_no_             CONSTANT VARCHAR2(2) :=  '*';

TYPE Mps_Record IS RECORD (
   work_day                 DATE,
   counter                  NUMBER,
   demand                   NUMBER,
   time_phased_ss_level     NUMBER,
   act_receipt              NUMBER,
   mps                      NUMBER,
   projected_onhand         NUMBER,
   ms_receipt_activity_seq  NUMBER );

TYPE Mps_Array_ IS TABLE OF Mps_Record INDEX BY PLS_INTEGER;


-----------------------------------------------------------------------------
-------------------- IMPLEMENTATION METHOD DECLARATIONS ---------------------
-----------------------------------------------------------------------------

PROCEDURE Create_Line_Sched_Receipts___ (
   contract_      IN VARCHAR2,
   part_no_       IN VARCHAR2,
   png_           IN VARCHAR2,
   ms_set_        IN NUMBER,
   line_no_       IN NUMBER,
   due_date_      IN DATE,
   manuf_calendar_ IN VARCHAR2,
   qty_due_       IN NUMBER,
   start_crp_calc_ IN BOOLEAN );

PROCEDURE Generate_Supply___(
   applied_dis_ord_date_          OUT    DATE,
   adjusted_increment_qty_        IN OUT NOCOPY NUMBER,
   do_supply_arr_                 IN OUT NOCOPY Supply_Collection,
   contract_                      IN     VARCHAR2,
   part_no_                       IN     VARCHAR2,
   png_                           IN     VARCHAR2,
   ms_set_                        IN     NUMBER,
   split_manuf_acquired_          IN     VARCHAR2,
   demand_tf_                     IN     DATE,
   planning_tf_                   IN     DATE,
   calendar_id_                   IN     VARCHAR2,
   unit_meas_                     IN     VARCHAR2,
   is_part_internally_sourced_    IN     VARCHAR2,
   manuf_supply_type_             IN     VARCHAR2,
   pur_lu_req_exists_             IN     BOOLEAN,
   ms_date_                       IN     DATE,
   acquired_supply_type_          IN     VARCHAR2,
   stock_management_              IN     VARCHAR2,
   lead_time_code_db_             IN     VARCHAR2,
   order_requisition_             IN     VARCHAR2,
   start_crp_calc_                IN     BOOLEAN);

PROCEDURE Generate_Supply_Schedules___(
   contract_    IN VARCHAR2,
   part_no_     IN VARCHAR2,
   png_         IN VARCHAR2,
   ms_set_      IN NUMBER,
   demand_tf_   IN DATE,
   planning_tf_ IN DATE );

PROCEDURE Remove_Supply_Schedules___ (
   contract_    IN VARCHAR2,
   part_no_     IN VARCHAR2,
   png_         IN VARCHAR2,
   demand_tf_   IN DATE,
   planning_tf_ IN DATE );

PROCEDURE Check_For_Zero_Rate___ (
   mps_arr_                     IN OUT NOCOPY Mps_Array_,
   records_deleted_cnt_         IN OUT NOCOPY PLS_INTEGER,
   current_index_               IN PLS_INTEGER,
   contract_                    IN VARCHAR2,
   part_no_                     IN VARCHAR2,
   png_                         IN VARCHAR2 );

PROCEDURE Lot_Size_And_Create_New_Mps___ (
   mps_arr_                     IN OUT NOCOPY Mps_Array_,
   current_index_               IN PLS_INTEGER,
   new_mps_                     IN NUMBER,
   contract_                    IN VARCHAR2,
   part_no_                     IN VARCHAR2,
   png_                         IN VARCHAR2,
   ms_set_                      IN VARCHAR2,
   ptf_date_                    IN DATE,
   calendar_id_                 IN VARCHAR2,
   inventory_part_plan_rec_     IN Inventory_Part_Planning_API.Public_Rec,
   start_crp_calc_              IN BOOLEAN,
   shop_order_proposal_flag_db_ IN VARCHAR2,
   lead_time_code_db_           IN VARCHAR2 );

PROCEDURE Create_New_Mps___ (
   mps_arr_                     IN OUT NOCOPY Mps_Array_,
   current_index_               IN PLS_INTEGER,
   new_mps_                     IN NUMBER,
   contract_                    IN VARCHAR2,
   part_no_                     IN VARCHAR2,
   png_                         IN VARCHAR2,
   ms_set_                      IN VARCHAR2,
   ptf_date_                    IN DATE,
   start_crp_calc_              IN BOOLEAN,
   shop_order_proposal_flag_db_ IN VARCHAR2,
   calendar_id_                 IN VARCHAR2,
   vendor_no_                   IN VARCHAR2 DEFAULT NULL );

FUNCTION Find_Local_Index___ (
   mps_arr_    IN Mps_Array_,
   work_day_   IN DATE ) RETURN PLS_INTEGER;

FUNCTION Find_Local_Index___ (
   mps_arr_    IN Mps_Array_,
   counter_    IN NUMBER ) RETURN PLS_INTEGER;

FUNCTION Find_Local_Index_Forward___ (
   mps_arr_    IN Mps_Array_,
   work_day_   IN DATE ) RETURN PLS_INTEGER;

FUNCTION Find_Local_Index_Backward___ (
   mps_arr_    IN Mps_Array_,
   work_day_   IN DATE ) RETURN PLS_INTEGER;

FUNCTION Get_Available_Mps_For_Week___ (
   contract_                    IN VARCHAR2,
   part_no_                     IN VARCHAR2,
   png_                         IN VARCHAR2,
   ms_set_                      IN NUMBER,
   used_required_date_          IN DATE,
   max_size_                    IN NUMBER,
   orig_fcst_date_              IN DATE,
   qty_to_plan_                 IN NUMBER,
   week_start_                  IN DATE DEFAULT NULL ) RETURN NUMBER;

PROCEDURE Std_Mul_Qty_Calculation___ (
   mps_arr_                     IN OUT NOCOPY Mps_Array_,
   current_index_               IN PLS_INTEGER,
   new_mps_                     IN NUMBER,
   contract_                    IN VARCHAR2,
   part_no_                     IN VARCHAR2,
   png_                         IN VARCHAR2,
   ms_set_                      IN NUMBER,
   ptf_date_                    IN DATE,
   shop_order_proposal_flag_db_ IN VARCHAR2,
   calendar_id_                 IN VARCHAR2 );

-----------------------------------------------------------------------------
-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
-----------------------------------------------------------------------------

PROCEDURE Shipment_Update (
   contract_         IN VARCHAR2,
   part_no_          IN VARCHAR2,
   qty_shipped_      IN NUMBER,
   planned_due_date_ IN DATE DEFAULT NULL )
IS
   
   PROCEDURE Core (
      contract_         IN VARCHAR2,
      part_no_          IN VARCHAR2,
      qty_shipped_      IN NUMBER,
      planned_due_date_ IN DATE DEFAULT NULL )
   IS
      ms_set_                      INTEGER := 1;
      local_forecast_lev0_         NUMBER;
      local_forecast_lev1_         NUMBER;
      local_consumed_forecast_     NUMBER;
      local_qty_shipped_           NUMBER;
      forecast_adjustment_qty_     NUMBER;
      local_work_day_              DATE;
      calendar_id_                 VARCHAR2(10);
      level1_part_rec_             Level_1_Part_API.Public_Rec := Level_1_Part_API.Get(contract_, part_no_, '*');
      part_consume_flag_db_        VARCHAR2(20) := Inventory_Part_API.Get_Forecast_Consump_Flag_Db (contract_, part_no_);
   
      massch_running               EXCEPTION;
   
      CURSOR shipment_update IS
         SELECT ms_date,
                NVL(forecast_lev0,     0) forecast_lev0,
                NVL(forecast_lev1,     0) forecast_lev1,
                NVL(consumed_forecast, 0) consumed_forecast
         FROM LEVEL_1_FORECAST_TAB
         WHERE contract = contract_
         AND   part_no  = part_no_
         AND   png      = '*'
         AND   ms_set   = ms_set_
         AND   NVL(consumed_forecast, 0) > 0
         AND   ms_date <= local_work_day_
         ORDER BY ms_date DESC;
   
      CURSOR shipment_update_forward IS
         SELECT ms_date,
                NVL(forecast_lev0,     0) forecast_lev0,
                NVL(forecast_lev1,     0) forecast_lev1,
                NVL(consumed_forecast, 0) consumed_forecast
         FROM LEVEL_1_FORECAST_TAB
         WHERE contract = contract_
         AND   part_no  = part_no_
         AND   png      = '*'
         AND   ms_set   = ms_set_
         AND   NVL(consumed_forecast, 0) > 0
         AND   ms_date > local_work_day_
         ORDER BY ms_date ASC;
   
   BEGIN
   
      IF (Level_1_Part_API.Check_Exist(contract_, part_no_, '*') AND
          Level_1_Part_API.Check_Active(contract_, part_no_, '*') = 1) THEN
   
         -- check if Level 1 is running for this part, and if so, do not
         -- allow booking of orders for this part.
         IF ( Level_1_Part_Util_API.Is_Level_One_Running(contract_, part_no_, '*', ms_set_  ) = 1 ) THEN
            RAISE massch_running;
         END IF;
   
         local_qty_shipped_ := qty_shipped_;
         local_work_day_    := TRUNC(planned_due_date_);
         calendar_id_       := Site_API.Get_Manuf_Calendar_Id (contract_);
         local_work_day_    := TRUNC(Work_Time_Calendar_API.Get_Prior_Work_Day (calendar_id_, local_work_day_));
   
   
         FOR shipment_update_rec IN shipment_update LOOP
   
            EXIT WHEN local_qty_shipped_ = 0;
   
            IF (shipment_update_rec.consumed_forecast > 0) THEN
   
               IF (local_qty_shipped_ > shipment_update_rec.consumed_forecast) THEN
                  local_qty_shipped_       := local_qty_shipped_ - shipment_update_rec.consumed_forecast;
                  local_consumed_forecast_ := 0;
                  forecast_adjustment_qty_ := shipment_update_rec.consumed_forecast;
               ELSE
                  local_consumed_forecast_ := shipment_update_rec.consumed_forecast - local_qty_shipped_;
                  forecast_adjustment_qty_ := local_qty_shipped_;
                  local_qty_shipped_       := 0;
               END IF;
   
               IF (shipment_update_rec.forecast_lev1 > 0) THEN
                  IF (forecast_adjustment_qty_ > shipment_update_rec.forecast_lev1) THEN
                     local_forecast_lev1_ := 0;
                     forecast_adjustment_qty_ := forecast_adjustment_qty_ - shipment_update_rec.forecast_lev1;
                  ELSE
                     local_forecast_lev1_ := shipment_update_rec.forecast_lev1 - forecast_adjustment_qty_;
                     forecast_adjustment_qty_ := 0;
                  END IF;
               END IF;
   
               IF (forecast_adjustment_qty_ > 0) THEN
                  IF (shipment_update_rec.forecast_lev0 > 0) THEN
                     IF (forecast_adjustment_qty_ > shipment_update_rec.forecast_lev0) THEN
                        local_forecast_lev0_ := 0;
                        forecast_adjustment_qty_ := forecast_adjustment_qty_ - shipment_update_rec.forecast_lev0;
                     ELSE
                        local_forecast_lev0_ := shipment_update_rec.forecast_lev0 - forecast_adjustment_qty_;
                        forecast_adjustment_qty_ := 0;
                     END IF;
                  END IF;
               END IF;
   
               -- update level 1 forecast rec with shipment qty adjustment.
               Level_1_Forecast_API.Batch_Modify__ (
                  contract_            => contract_,
                  part_no_             => part_no_,
                  png_                 => '*',
                  ms_set_              => ms_set_,
                  activity_seq_        => 0,
                  ms_date_             => shipment_update_rec.ms_date,
                  parent_contract_     => NULL,
                  parent_part_         => NULL,
                  forecast_lev0_       => local_forecast_lev0_,
                  forecast_lev1_       => local_forecast_lev1_,
                  consumed_forecast_   => local_consumed_forecast_,
                  actual_demand_       => NULL,
                  planned_demand_      => NULL,
                  supply_              => NULL,
                  consumed_supply_     => NULL,
                  firm_orders_         => NULL,
                  sched_orders_        => NULL,
                  rel_ord_rcpt_        => NULL,
                  master_sched_rcpt_   => NULL,
                  avail_to_prom_       => NULL,
                  roll_up_rcpt_        => NULL,
                  net_avail_           => NULL,
                  proj_avail_          => NULL,
                  mtr_demand_qty_      => NULL,
                  mtr_supply_qty_      => NULL,
                  offset_              => NULL,
                  roll_flag_db_        => NULL,
                  sysgen_flag_         => NULL,
                  master_sched_status_ => NULL,
                  method_              => 'UPDATE' );
   
            END IF;
   
         END LOOP;
         
         IF level1_part_rec_.fwd_forecast_consumption > 0 AND (level1_part_rec_.promise_method = 'ATP' 
            OR part_consume_flag_db_ = Inv_Part_Forecast_Consum_API.DB_NO_ONLINE_CONSUMPTION) THEN         
            
            FOR shipment_update_rec IN shipment_update_forward LOOP
               EXIT WHEN local_qty_shipped_ = 0;
   
               IF (shipment_update_rec.consumed_forecast > 0) THEN
   
                  IF (local_qty_shipped_ > shipment_update_rec.consumed_forecast) THEN
                     local_qty_shipped_       := local_qty_shipped_ - shipment_update_rec.consumed_forecast;
                     local_consumed_forecast_ := 0;
                     forecast_adjustment_qty_ := shipment_update_rec.consumed_forecast;
                  ELSE
                     local_consumed_forecast_ := shipment_update_rec.consumed_forecast - local_qty_shipped_;
                     forecast_adjustment_qty_ := local_qty_shipped_;
                     local_qty_shipped_       := 0;
                  END IF;
   
                  IF (shipment_update_rec.forecast_lev1 > 0) THEN
                     IF (forecast_adjustment_qty_ > shipment_update_rec.forecast_lev1) THEN
                        local_forecast_lev1_ := 0;
                        forecast_adjustment_qty_ := forecast_adjustment_qty_ - shipment_update_rec.forecast_lev1;
                     ELSE
                        local_forecast_lev1_ := shipment_update_rec.forecast_lev1 - forecast_adjustment_qty_;
                        forecast_adjustment_qty_ := 0;
                     END IF;
                  END IF;
   
                  IF (forecast_adjustment_qty_ > 0) THEN
                     IF (shipment_update_rec.forecast_lev0 > 0) THEN
                        IF (forecast_adjustment_qty_ > shipment_update_rec.forecast_lev0) THEN
                           local_forecast_lev0_ := 0;
                           forecast_adjustment_qty_ := forecast_adjustment_qty_ - shipment_update_rec.forecast_lev0;
                        ELSE
                           local_forecast_lev0_ := shipment_update_rec.forecast_lev0 - forecast_adjustment_qty_;
                           forecast_adjustment_qty_ := 0;
                        END IF;
                     END IF;
                  END IF;
                  -- update level 1 forecast rec with shipment qty adjustment.
                  Level_1_Forecast_API.Batch_Modify__ (
                     contract_            => contract_,
                     part_no_             => part_no_,
                     png_                 => '*',
                     ms_set_              => ms_set_,
                     activity_seq_        => 0,
                     ms_date_             => shipment_update_rec.ms_date,
                     parent_contract_     => NULL,
                     parent_part_         => NULL,
                     forecast_lev0_       => local_forecast_lev0_,
                     forecast_lev1_       => local_forecast_lev1_,
                     consumed_forecast_   => local_consumed_forecast_,
                     actual_demand_       => NULL,
                     planned_demand_      => NULL,
                     supply_              => NULL,
                     consumed_supply_     => NULL,
                     firm_orders_         => NULL,
                     sched_orders_        => NULL,
                     rel_ord_rcpt_        => NULL,
                     master_sched_rcpt_   => NULL,
                     avail_to_prom_       => NULL,
                     roll_up_rcpt_        => NULL,
                     net_avail_           => NULL,
                     proj_avail_          => NULL,
                     mtr_demand_qty_      => NULL,
                     mtr_supply_qty_      => NULL,
                     offset_              => NULL,
                     roll_flag_db_        => NULL,
                     sysgen_flag_         => NULL,
                     master_sched_status_ => NULL,
                     method_              => 'UPDATE' );
   
               END IF;
            END LOOP;
         END IF;
      ELSE
         $IF Component_Mrp_SYS.INSTALLED $THEN
            -- Update MRP Spares forecast consumtion
            Spare_Part_Forecast_Util_API.Shipment_Update(
                         contract_,
                         part_no_,
                         NVL(qty_shipped_,0),
                         planned_due_date_) ;
         $ELSE
           -- forecast flag is set but part is not planned by either MS or MRP.
           ERROR_SYS.Appl_General(lu_name_, 'CONSMSINSTERR: Shipment update of forecast cannot occur because Site :P1 Part No :P2 is not planned by MS or MRP.', contract_, part_no_);
         $END
      END IF;
   
   EXCEPTION
      WHEN massch_running THEN
         Error_Sys.Appl_General(lu_name_, 'LEV1RUNNING: Level 1 is currently running for Site :P1 Part No :P2.', contract_, part_no_);
      WHEN OTHERS THEN
         IF Error_SYS.Is_Foundation_Error(SQLCODE) THEN
            RAISE;
         END IF;
   
         Error_Sys.Appl_General (lu_name_, 'MSSHIPUPD: Error :P1 occurred while running LEVEL_1_FORECAST_UTIL_API.Massch_Shipment_Update for Site :P2 Part No :P3.', SQLERRM, contract_, part_no_);
   END Core;

BEGIN
   General_SYS.Init_Method(LEVEL_1_FORECAST_UTIL_API.lu_name_, 'LEVEL_1_FORECAST_UTIL_API', 'Shipment_Update');
   Core(contract_, part_no_, qty_shipped_, planned_due_date_);
END Shipment_Update;


PROCEDURE Shipment_Update (
   contract_         IN VARCHAR2,
   part_no_          IN VARCHAR2,
   activity_seq_     IN NUMBER,
   qty_shipped_      IN NUMBER,
   planned_due_date_ IN DATE )
IS
   
   PROCEDURE Core (
      contract_         IN VARCHAR2,
      part_no_          IN VARCHAR2,
      activity_seq_     IN NUMBER,
      qty_shipped_      IN NUMBER,
      planned_due_date_ IN DATE )
   IS
      ms_set_                      INTEGER := 1;
      local_forecast_lev0_         NUMBER;
      local_forecast_lev1_         NUMBER;
      local_consumed_forecast_     NUMBER;
      local_qty_shipped_           NUMBER;
      forecast_adjustment_qty_     NUMBER;
      local_work_day_              DATE;
      calendar_id_                 VARCHAR2(10);
      project_id_                  VARCHAR2(10);
      png_                         VARCHAR2(10);
      default_supply_activity_     NUMBER;
      level1_part_rec_             Level_1_Part_API.Public_Rec;
      part_consume_flag_db_        VARCHAR2(20) := Inventory_Part_API.Get_Forecast_Consump_Flag_Db (contract_, part_no_);
      
      massch_running               EXCEPTION;
   
      CURSOR shipment_update IS
         SELECT ms_date,
                NVL(forecast_lev0,     0) forecast_lev0,
                NVL(forecast_lev1,     0) forecast_lev1,
                NVL(consumed_forecast, 0) consumed_forecast
         FROM LEVEL_1_FORECAST_TAB
         WHERE contract = contract_
         AND   part_no  = part_no_
         AND   png      = png_
         AND   ms_set   = ms_set_
         AND   activity_seq = default_supply_activity_
         AND   NVL(consumed_forecast, 0) > 0
         AND   ms_date <= local_work_day_
         ORDER BY ms_date DESC;
         
      CURSOR shipment_update_forward IS
         SELECT ms_date,
                NVL(forecast_lev0,     0) forecast_lev0,
                NVL(forecast_lev1,     0) forecast_lev1,
                NVL(consumed_forecast, 0) consumed_forecast
         FROM LEVEL_1_FORECAST_TAB
         WHERE contract = contract_
         AND   part_no  = part_no_
         AND   png      = png_
         AND   ms_set   = ms_set_
         AND   NVL(consumed_forecast, 0) > 0
         AND   ms_date > local_work_day_
         ORDER BY ms_date ASC;
   BEGIN
      
      IF NVL(activity_seq_, 0) = 0 THEN
         png_ := '*';
      ELSE
         $IF Component_Pmrp_SYS.INSTALLED $THEN
            project_id_ := Activity_API.Get_Project_Id(activity_seq_);
            png_ := Png_Ppsa_API.Get_Attached_Png(contract_, project_id_, activity_seq_);
         $ELSE
            NULL;
         $END
      END IF;
      level1_part_rec_ := Level_1_Part_API.Get(contract_, part_no_, png_);
      
      IF (Level_1_Part_API.Check_Active(contract_, part_no_, png_) = 1) THEN
   
         -- check if Level 1 is running for this part, and if so, do not
         -- allow booking of orders for this part.
         IF ( Level_1_Part_Util_API.Is_Level_One_Running (contract_, part_no_, png_, ms_set_  ) = 1 ) THEN
            RAISE massch_running;
         END IF;
   
         local_work_day_ := TRUNC(planned_due_date_);
         calendar_id_    := Site_API.Get_Manuf_Calendar_Id (contract_);
         local_work_day_ := TRUNC(Work_Time_Calendar_API.Get_Prior_Work_Day (calendar_id_, local_work_day_));
         default_supply_activity_ := Level_1_Part_API.Get_Ms_Receipt_Activity_Seq(contract_, part_no_, png_);
         
         IF (qty_shipped_ > 0) THEN -- Issue qty
            local_qty_shipped_ := qty_shipped_;
            FOR shipment_update_rec IN shipment_update LOOP
   
               EXIT WHEN local_qty_shipped_ = 0;
   
               IF (shipment_update_rec.consumed_forecast > 0) THEN
   
                  IF (local_qty_shipped_ > shipment_update_rec.consumed_forecast) THEN
                     local_qty_shipped_       := local_qty_shipped_ - shipment_update_rec.consumed_forecast;
                     local_consumed_forecast_ := 0;
                     forecast_adjustment_qty_ := shipment_update_rec.consumed_forecast;
                  ELSE
                     local_consumed_forecast_ := shipment_update_rec.consumed_forecast - local_qty_shipped_;
                     forecast_adjustment_qty_ := local_qty_shipped_;
                     local_qty_shipped_       := 0;
                  END IF;
   
                  IF (shipment_update_rec.forecast_lev1 > 0) THEN
                     IF (forecast_adjustment_qty_ > shipment_update_rec.forecast_lev1) THEN
                        local_forecast_lev1_ := 0;
                        forecast_adjustment_qty_ := forecast_adjustment_qty_ - shipment_update_rec.forecast_lev1;
                     ELSE
                        local_forecast_lev1_ := shipment_update_rec.forecast_lev1 - forecast_adjustment_qty_;
                        forecast_adjustment_qty_ := 0;
                     END IF;
                  END IF;
   
                  IF (forecast_adjustment_qty_ > 0) THEN
                     IF (shipment_update_rec.forecast_lev0 > 0) THEN
                        IF (forecast_adjustment_qty_ > shipment_update_rec.forecast_lev0) THEN
                           local_forecast_lev0_ := 0;
                           forecast_adjustment_qty_ := forecast_adjustment_qty_ - shipment_update_rec.forecast_lev0;
                        ELSE
                           local_forecast_lev0_ := shipment_update_rec.forecast_lev0 - forecast_adjustment_qty_;
                           forecast_adjustment_qty_ := 0;
                        END IF;
                     END IF;
                  END IF;
   
                  -- update level 1 forecast rec with shipment qty adjustment.
                  Level_1_Forecast_API.Batch_Modify__ (
                     contract_            => contract_,
                     part_no_             => part_no_,
                     png_                 => png_,
                     ms_set_              => ms_set_,
                     activity_seq_        => default_supply_activity_,
                     ms_date_             => shipment_update_rec.ms_date,
                     parent_contract_     => NULL,
                     parent_part_         => NULL,
                     forecast_lev0_       => local_forecast_lev0_,
                     forecast_lev1_       => local_forecast_lev1_,
                     consumed_forecast_   => local_consumed_forecast_,
                     actual_demand_       => NULL,
                     planned_demand_      => NULL,
                     supply_              => NULL,
                     consumed_supply_     => NULL,
                     firm_orders_         => NULL,
                     sched_orders_        => NULL,
                     rel_ord_rcpt_        => NULL,
                     master_sched_rcpt_   => NULL,
                     avail_to_prom_       => NULL,
                     roll_up_rcpt_        => NULL,
                     net_avail_           => NULL,
                     proj_avail_          => NULL,
                     mtr_demand_qty_      => NULL,
                     mtr_supply_qty_      => NULL,
                     offset_              => NULL,
                     roll_flag_db_        => NULL,
                     sysgen_flag_         => NULL,
                     master_sched_status_ => NULL,
                     method_              => 'UPDATE' );
   
               END IF;
   
            END LOOP;
         
            IF level1_part_rec_.fwd_forecast_consumption > 0 AND (level1_part_rec_.promise_method = 'ATP' 
               OR part_consume_flag_db_ = Inv_Part_Forecast_Consum_API.DB_NO_ONLINE_CONSUMPTION) THEN         
            
               FOR shipment_update_rec IN shipment_update_forward LOOP
                  EXIT WHEN local_qty_shipped_ = 0;
   
                  IF (shipment_update_rec.consumed_forecast > 0) THEN
   
                     IF (local_qty_shipped_ > shipment_update_rec.consumed_forecast) THEN
                        local_qty_shipped_       := local_qty_shipped_ - shipment_update_rec.consumed_forecast;
                        local_consumed_forecast_ := 0;
                        forecast_adjustment_qty_ := shipment_update_rec.consumed_forecast;
                     ELSE
                        local_consumed_forecast_ := shipment_update_rec.consumed_forecast - local_qty_shipped_;
                        forecast_adjustment_qty_ := local_qty_shipped_;
                        local_qty_shipped_       := 0;
                     END IF;
   
                     IF (shipment_update_rec.forecast_lev1 > 0) THEN
                        IF (forecast_adjustment_qty_ > shipment_update_rec.forecast_lev1) THEN
                           local_forecast_lev1_ := 0;
                           forecast_adjustment_qty_ := forecast_adjustment_qty_ - shipment_update_rec.forecast_lev1;
                        ELSE
                           local_forecast_lev1_ := shipment_update_rec.forecast_lev1 - forecast_adjustment_qty_;
                           forecast_adjustment_qty_ := 0;
                        END IF;
                     END IF;
   
                     IF (forecast_adjustment_qty_ > 0) THEN
                        IF (shipment_update_rec.forecast_lev0 > 0) THEN
                           IF (forecast_adjustment_qty_ > shipment_update_rec.forecast_lev0) THEN
                              local_forecast_lev0_ := 0;
                              forecast_adjustment_qty_ := forecast_adjustment_qty_ - shipment_update_rec.forecast_lev0;
                           ELSE
                              local_forecast_lev0_ := shipment_update_rec.forecast_lev0 - forecast_adjustment_qty_;
                              forecast_adjustment_qty_ := 0;
                           END IF;
                        END IF;
                     END IF;
                     -- update level 1 forecast rec with shipment qty adjustment.
                     Level_1_Forecast_API.Batch_Modify__ (
                        contract_            => contract_,
                        part_no_             => part_no_,
                        png_                 => png_,
                        ms_set_              => ms_set_,
                        activity_seq_        => default_supply_activity_,
                        ms_date_             => shipment_update_rec.ms_date,
                        parent_contract_     => NULL,
                        parent_part_         => NULL,
                        forecast_lev0_       => local_forecast_lev0_,
                        forecast_lev1_       => local_forecast_lev1_,
                        consumed_forecast_   => local_consumed_forecast_,
                        actual_demand_       => NULL,
                        planned_demand_      => NULL,
                        supply_              => NULL,
                        consumed_supply_     => NULL,
                        firm_orders_         => NULL,
                        sched_orders_        => NULL,
                        rel_ord_rcpt_        => NULL,
                        master_sched_rcpt_   => NULL,
                        avail_to_prom_       => NULL,
                        roll_up_rcpt_        => NULL,
                        net_avail_           => NULL,
                        proj_avail_          => NULL,
                        mtr_demand_qty_      => NULL,
                        mtr_supply_qty_      => NULL,
                        offset_              => NULL,
                        roll_flag_db_        => NULL,
                        sysgen_flag_         => NULL,
                        master_sched_status_ => NULL,
                        method_              => 'UPDATE' );
   
                  END IF;
               END LOOP;
            END IF;
         ELSE  -- Unissue qty
            local_qty_shipped_ := (-1) * qty_shipped_;
            -- MAJOSE UNISSUE NOT RESOLVED
         
         END IF;
      END IF;
   
   EXCEPTION
      WHEN massch_running THEN
         Error_Sys.Appl_General(lu_name_, 'LEV1RUNNING: Level 1 is currently running for Site :P1 Part No :P2.', contract_, part_no_);
      WHEN OTHERS THEN
         IF Error_SYS.Is_Foundation_Error(SQLCODE) THEN
            RAISE;
         END IF;
   
         Error_Sys.Appl_General (lu_name_, 'MSSHIPUPD: Error :P1 occurred while running LEVEL_1_FORECAST_UTIL_API.Massch_Shipment_Update for Site :P2 Part No :P3.', SQLERRM, contract_, part_no_);
   END Core;

BEGIN
   General_SYS.Init_Method(LEVEL_1_FORECAST_UTIL_API.lu_name_, 'LEVEL_1_FORECAST_UTIL_API', 'Shipment_Update');
   Core(contract_, part_no_, activity_seq_, qty_shipped_, planned_due_date_);
END Shipment_Update;


PROCEDURE Control_Consumption (
   result_code_                 OUT VARCHAR2,
   available_qty_               OUT NUMBER,
   earliest_available_date_     OUT DATE,
   contract_                    IN VARCHAR2,
   part_no_                     IN VARCHAR2,
   new_demand_qty_              IN NUMBER,
   old_demand_qty_              IN NUMBER,
   new_due_date_                IN DATE,
   old_due_date_                IN DATE,
   source_type_                 IN VARCHAR2,
   order_line_cancellation_     IN BOOLEAN )
IS
   
   PROCEDURE Core (
      result_code_                 OUT VARCHAR2,
      available_qty_               OUT NUMBER,
      earliest_available_date_     OUT DATE,
      contract_                    IN VARCHAR2,
      part_no_                     IN VARCHAR2,
      new_demand_qty_              IN NUMBER,
      old_demand_qty_              IN NUMBER,
      new_due_date_                IN DATE,
      old_due_date_                IN DATE,
      source_type_                 IN VARCHAR2,
      order_line_cancellation_     IN BOOLEAN )
   IS
      ms_set_                    NUMBER := 1;
      calendar_id_               VARCHAR2(10) := Site_API.Get_Manuf_Calendar_Id(contract_);
      last_run_date_             DATE;
      ptf_date_                  DATE;
      next_work_day_             DATE;
      calendar_state_            WORK_TIME_CALENDAR_TAB.rowstate%TYPE;
      level_1_part_rec_          Level_1_Part_API.Public_Rec;
      msg_                       VARCHAR2(32000);
      count_                     NUMBER;
      job_id_tab_                Message_Sys.name_table;
      attrib_tab_                Message_Sys.line_table;
      local_calendar_            VARCHAR2(10);
      start_consumption_         BOOLEAN:= TRUE;
      consume_supply_online_     BOOLEAN;
   
   BEGIN
      -- this method is called from ORDER when an MS or Spares part is ordered
      -- initially, the order qty for an existing line is adjusted, or the line is
      -- cancelled; the method determines whether the part is an MS or Spares part
      -- and whether forecasts are to be consumed or unconsumed.
   
      -- make the non-dynamic call first because it's quickest.
      -- check if part exists in MASSCH, and if so, is active. if either
      -- of these conditions not satisfied, do not allow booking of orders
      -- for this part.
   
      IF (Transaction_SYS.Is_Session_Deferred()) THEN
         Transaction_SYS.Get_Executing_Job_Arguments(msg_, 'Work_Time_Calendar_API.Set_Calendar_Generated__');
         Message_Sys.Get_Attributes(msg_, count_, job_id_tab_, attrib_tab_);
         WHILE (count_ > 0) LOOP
            local_calendar_ := Client_SYS.Get_Item_Value('CALENDAR_ID', attrib_tab_(count_));
            IF calendar_id_ = local_calendar_ THEN
               start_consumption_ := FALSE;
               EXIT;
            END IF;
            count_ := count_ - 1;
         END LOOP;
      END IF;
   
      IF start_consumption_ THEN
         calendar_state_ := Work_Time_Calendar_API.Get_Objstate( calendar_id_ );
         IF calendar_state_ = 'Generated' THEN
            IF (Level_1_Part_API.Check_Exist(contract_, part_no_, '*') AND
                Level_1_Part_API.Check_Active(contract_, part_no_, '*') = 1) THEN
   
               level_1_part_rec_ := Level_1_Part_API.Get(contract_, part_no_, '*');
   
               last_run_date_ := TRUNC(NVL(Level_1_Part_By_Ms_Set_API.Get_Last_Run_Date (contract_,
                                                                                         part_no_,
                                                                                         '*',
                                                                                         ms_set_),
                                       Site_API.Get_Site_Date(contract_)));
   
               ptf_date_ := Level_1_Part_API.Get_Planning_Tf_Date(contract_, part_no_, '*', ms_set_);
               next_work_day_ := TRUNC(Work_Time_Calendar_API.Get_Next_Work_Day(calendar_id_, ptf_date_));
               result_code_ := 'SUCCESS';
   
               IF nvl(new_due_date_, old_due_date_) > ptf_date_ THEN
                  consume_supply_online_ := FALSE;
               ELSE
                  consume_supply_online_ := TRUE;
               END IF;
               
               IF trunc(nvl(new_due_date_,old_due_date_)) = trunc(nvl(old_due_date_, new_due_date_)) THEN
                  IF (NVL(new_demand_qty_, 0) > NVL(old_demand_qty_, 0)) THEN
   
                     -- ordering more.
                     IF source_type_ <> 'SO' THEN
                        Massch_Atp_Check__ (
                           result_code_             => result_code_,
                           available_qty_           => available_qty_,
                           earliest_available_date_ => earliest_available_date_,
                           contract_                => contract_,
                           part_no_                 => part_no_,
                           png_                     => '*',
                           activity_seq_            => level_1_part_rec_.ms_receipt_activity_seq,
                           order_line_qty_          => NVL(new_demand_qty_, 0) - NVL(old_demand_qty_, 0),
                           order_line_due_date_     => new_due_date_,
                           promise_method_db_       => level_1_part_rec_.promise_method,
                           calendar_id_             => calendar_id_,
                           ptf_date_                => ptf_date_ );
                     END IF;
                     IF result_code_ = 'SUCCESS' THEN
                        -- consume forecast for new order lines or for increase in qty of
                        -- existing lines.
                        Consume_Forecast (
                           contract_                 => contract_,
                           part_no_                  => part_no_,
                           png_                      => '*',
                           ms_set_                   => ms_set_,
                           total_demand_activity_    => level_1_part_rec_.ms_receipt_activity_seq,
                           default_supply_activity_  => level_1_part_rec_.ms_receipt_activity_seq,
                           order_line_new_qty_       => NVL(new_demand_qty_, 0),
                           order_line_old_qty_       => NVL(old_demand_qty_, 0),
                           order_line_due_date_      => new_due_date_,
                           source_type_              => source_type_,
                           promise_method_db_        => level_1_part_rec_.promise_method,
                           forecast_consumption_wnd_ => NVL(level_1_part_rec_.forecast_consumption_wnd, 0),
                           fwd_forecast_consumption_ => NVL(level_1_part_rec_.fwd_forecast_consumption, 0),
                           consuming_fcst_online_    => TRUE,
                           calendar_id_              => calendar_id_);
   
                        -- consume supply for new order lines or for increase in qty of
                        -- existing lines.
                        Consume_Supply (
                           contract_                   => contract_,
                           part_no_                    => part_no_,
                           png_                        => '*',
                           ms_set_                     => ms_set_,
                           activity_seq_               => 0,
                           order_line_new_qty_         => NVL(new_demand_qty_, 0),
                           order_line_old_qty_         => NVL(old_demand_qty_, 0),
                           order_line_due_date_        => new_due_date_,
                           promise_method_db_          => level_1_part_rec_.promise_method,
                           calendar_id_                => calendar_id_,
                           consuming_fcst_online_      => consume_supply_online_,
                           source_type_                => source_type_,
                           order_line_cancellation_    => order_line_cancellation_);
   
   
                        -- recalculate ATP.
                        Level_1_Onhand_Util_API.Calc_Avail_To_Promise_(
                           contract_,
                           part_no_,
                           '*',
                           ms_set_,
                           NVL(last_run_date_,Site_API.Get_Site_Date(contract_)));
                     END IF;
                  ELSE -- ordering less.
      
                     -- unconsume forecasts.
                     Unconsume_Forecast (
                        contract_                  => contract_,
                        part_no_                   => part_no_,
                        png_                       => '*',
                        ms_set_                    => ms_set_,
                        ms_receipt_activity_seq_   => level_1_part_rec_.ms_receipt_activity_seq,
                        new_demand_qty_            => NVL(new_demand_qty_, 0),
                        old_demand_qty_            => NVL(old_demand_qty_, 0),
                        new_due_date_              => new_due_date_,
                        old_due_date_              => old_due_date_,
                        source_type_               => source_type_,
                        promise_method_db_         => level_1_part_rec_.promise_method,
                        calendar_id_               => calendar_id_,
                        forecast_consumption_wnd_  => NVL(level_1_part_rec_.forecast_consumption_wnd, 0),
                        fwd_forecast_consumption_  => NVL(level_1_part_rec_.fwd_forecast_consumption, 0));
   
                     -- unconsume supply.
                     Unconsume_Supply (
                        contract_                  => contract_,
                        part_no_                   => part_no_,
                        png_                       => '*',
                        ms_set_                    => ms_set_,
                        new_demand_qty_            => NVL(new_demand_qty_, 0),
                        old_demand_qty_            => NVL(old_demand_qty_, 0),
                        new_due_date_              => new_due_date_,
                        old_due_date_              => old_due_date_,
                        consuming_fcst_online_     => consume_supply_online_,
                        source_type_               => source_type_,
                        promise_method_db_         => level_1_part_rec_.promise_method,
                        calendar_id_               => calendar_id_,
                        order_line_cancellation_   => order_line_cancellation_);
   
                     -- recalculate ATP.
                     Level_1_Onhand_Util_API.Calc_Avail_To_Promise_(contract_, part_no_, '*', 1, NVL(last_run_date_, Site_API.Get_Site_Date(contract_)));
   
                  END IF; -- consuming forecast.
               ELSE -- new_due_date_ != new_due_date_
                  -- If planned due date is changed then unconsume the existing forecast on old_due_date_
                  -- then try to consume forecast on the new_due_date_
                  -- unconsume forecasts on old_due_date_.
   
                  -- Unconsumed existing forecasts should be undone
                  -- if the available to promise master scheduled check fails.
   
                  --@ApproveTransactionStatement(2009-11-03,kayolk)
                  SAVEPOINT before_unconsuming;
                  Unconsume_Forecast (
                     contract_                 => contract_,
                     part_no_                  => part_no_,
                     png_                      => '*',
                     ms_set_                   => ms_set_,
                     ms_receipt_activity_seq_  => level_1_part_rec_.ms_receipt_activity_seq,
                     new_demand_qty_           => 0,
                     old_demand_qty_           => NVL(old_demand_qty_, 0),
                     new_due_date_             => old_due_date_,
                     old_due_date_             => old_due_date_,
                     source_type_              => source_type_,
                     promise_method_db_        => level_1_part_rec_.promise_method,
                     calendar_id_              => calendar_id_,
                     forecast_consumption_wnd_ => NVL(level_1_part_rec_.forecast_consumption_wnd, 0),
                     fwd_forecast_consumption_ => NVL(level_1_part_rec_.fwd_forecast_consumption, 0));
   
                  -- unconsume supply on old_due_date_.
                  Unconsume_Supply (
                     contract_                 => contract_,
                     part_no_                  => part_no_,
                     ms_set_                   => ms_set_,
                     png_                      => '*',
                     new_demand_qty_           => 0,
                     old_demand_qty_           => NVL(old_demand_qty_, 0),
                     new_due_date_             => old_due_date_,
                     old_due_date_             => old_due_date_,
                     consuming_fcst_online_    => consume_supply_online_,
                     source_type_              => source_type_,
                     promise_method_db_        => level_1_part_rec_.promise_method,
                     calendar_id_              => calendar_id_,
                     order_line_cancellation_  => order_line_cancellation_);
   
                  -- a value to the order_line_qty_ parameter.
                  Massch_Atp_Check__ (
                     result_code_             => result_code_,
                     available_qty_           => available_qty_,
                     earliest_available_date_ => earliest_available_date_,
                     contract_                => contract_,
                     part_no_                 => part_no_,
                     png_                     => '*',
                     activity_seq_            => level_1_part_rec_.ms_receipt_activity_seq,
                     order_line_qty_          => NVL(new_demand_qty_, 0),
                     order_line_due_date_     => new_due_date_,
                     promise_method_db_       => level_1_part_rec_.promise_method,
                     calendar_id_             => calendar_id_,
                     ptf_date_                => ptf_date_ );
   
                  IF result_code_ != 'SUCCESS' THEN
                     -- Unconsumed existing forecasts should be undone
                     -- if the available to promise master scheduled check fails.
                     --@ApproveTransactionStatement(2009-11-03,kayolk)
                     ROLLBACK TO SAVEPOINT before_unconsuming;
                  END IF;
                  IF result_code_ = 'SUCCESS' THEN
      
                     -- consume forecast on new_due_date_.
                     Consume_Forecast (
                        contract_                 => contract_,
                        part_no_                  => part_no_,
                        png_                      => '*',
                        ms_set_                   => ms_set_,
                        total_demand_activity_    => level_1_part_rec_.ms_receipt_activity_seq,
                        default_supply_activity_  => level_1_part_rec_.ms_receipt_activity_seq,
                        order_line_new_qty_       => NVL(new_demand_qty_, 0),
                        order_line_old_qty_       => 0,
                        order_line_due_date_      => new_due_date_,
                        source_type_              => source_type_,
                        promise_method_db_        => level_1_part_rec_.promise_method,
                        forecast_consumption_wnd_ => NVL(level_1_part_rec_.forecast_consumption_wnd, 0),
                        fwd_forecast_consumption_ => NVL(level_1_part_rec_.fwd_forecast_consumption, 0),
                        calendar_id_              => calendar_id_,
                        consuming_fcst_online_    => TRUE);
      
                     -- consume supply on new_due_date_
                     Consume_Supply (
                        contract_                  => contract_,
                        part_no_                   => part_no_,
                        png_                       => '*',
                        ms_set_                    => ms_set_,
                        activity_seq_              => 0,
                        order_line_new_qty_        => NVL(new_demand_qty_, 0),
                        order_line_old_qty_        => 0,
                        order_line_due_date_       => new_due_date_,
                        promise_method_db_         => level_1_part_rec_.promise_method,
                        calendar_id_               => calendar_id_,
                        consuming_fcst_online_     => consume_supply_online_,
                        source_type_               => source_type_,
                        order_line_cancellation_   => order_line_cancellation_);
   
                     -- recalculate ATP.
                     Level_1_Onhand_Util_API.Calc_Avail_To_Promise_(
                        contract_,
                        part_no_,
                        '*',
                        ms_set_,
                        NVL(last_run_date_, Site_API.Get_Site_Date(contract_)));
                  END IF;
               END IF;
   
               IF (result_code_ = 'SUCCESS') THEN
                  DELETE LEVEL_1_FORECAST_TAB
                     WHERE contract = contract_
                     AND   part_no  = part_no_
                     AND   png      = '*'
                     AND   ms_set   = ms_set_
                     AND   activity_seq = 0
                     AND   nvl(planned_demand,0)    = 0
                     AND   nvl(actual_demand,0)     = 0
                     AND   nvl(forecast_lev0,0)     = 0
                     AND   nvl(forecast_lev1,0)     = 0
                     AND   nvl(consumed_forecast,0) = 0
                     AND   nvl(consumed_supply,0)   = 0
                     AND   nvl(supply,0)            = 0
                     AND   nvl(master_sched_rcpt,0) = 0
                     AND   ms_date NOT IN ( last_run_date_, next_work_day_);
               END IF;
            ELSE            
               $IF Component_Mrp_SYS.INSTALLED $THEN
                  Spare_Part_Forecast_Util_API.Control_Consumption(
                                  result_code_,
                                  available_qty_,
                                  earliest_available_date_,
                                  contract_,
                                  part_no_,
                                  NVL(new_demand_qty_,0),
                                  NVL(old_demand_qty_,0),
                                  new_due_date_,
                                  old_due_date_,
                                  source_type_ );
               $ELSE
                  -- forecast flag is set but part is not planned by either MS or MRP.
                  IF (NVL(new_demand_qty_, 0) > NVL(old_demand_qty_, 0)) THEN
                     ERROR_SYS.Appl_General(lu_name_, 'CONSMSINSTERR: Forecast and supply consumption cannot occur because Site :P1 Part No :P2 is not planned by MS or MRP.', contract_, part_no_);
                  ELSE
                     ERROR_SYS.Appl_General(lu_name_, 'UNCONSMSINSTERR: Forecast and supply unconsumption cannot occur because Site :P1 Part No :P2 is not planned by MS or MRP.', contract_, part_no_);
                  END IF;
               $END
            END IF;
         ELSE
            Error_SYS.Appl_General(lu_name_, 'MSCONCALNOTGEN: Forecast and supply consumption cannot occur because the site manufacturing calendar :P1 is not in state Generated.', calendar_id_);
         END IF;
      ELSE
         result_code_ := 'SUCCESS';
      END IF;
   
   EXCEPTION
      WHEN OTHERS THEN
   
         IF Error_SYS.Is_Foundation_Error(SQLCODE) THEN
            RAISE;
         END IF;
   
         Error_Sys.Appl_General (lu_name_, 'CONCON: Error :P1 occurred while running LEVEL_1_FORECAST_UTIL_API.Control_Consumption for Site :P2 Part No :P3.', SQLERRM, contract_, part_no_);
   END Core;

BEGIN
   General_SYS.Init_Method(LEVEL_1_FORECAST_UTIL_API.lu_name_, 'LEVEL_1_FORECAST_UTIL_API', 'Control_Consumption');
   Core(result_code_, available_qty_, earliest_available_date_, contract_, part_no_, new_demand_qty_, old_demand_qty_, new_due_date_, old_due_date_, source_type_, order_line_cancellation_);
END Control_Consumption;


PROCEDURE Consume_Forecast (
   contract_                 IN VARCHAR2,
   part_no_                  IN VARCHAR2,
   png_                      IN VARCHAR2,
   ms_set_                   IN NUMBER,
   total_demand_activity_    IN NUMBER,
   default_supply_activity_  IN NUMBER,
   order_line_new_qty_       IN NUMBER,
   order_line_old_qty_       IN NUMBER,
   order_line_due_date_      IN DATE,
   source_type_              IN VARCHAR2,
   promise_method_db_        IN VARCHAR2,
   forecast_consumption_wnd_ IN NUMBER,
   fwd_forecast_consumption_ IN NUMBER,
   calendar_id_              IN VARCHAR2,
   consuming_fcst_online_    IN BOOLEAN)
IS
   
   PROCEDURE Core (
      contract_                 IN VARCHAR2,
      part_no_                  IN VARCHAR2,
      png_                      IN VARCHAR2,
      ms_set_                   IN NUMBER,
      total_demand_activity_    IN NUMBER,
      default_supply_activity_  IN NUMBER,
      order_line_new_qty_       IN NUMBER,
      order_line_old_qty_       IN NUMBER,
      order_line_due_date_      IN DATE,
      source_type_              IN VARCHAR2,
      promise_method_db_        IN VARCHAR2,
      forecast_consumption_wnd_ IN NUMBER,
      fwd_forecast_consumption_ IN NUMBER,
      calendar_id_              IN VARCHAR2,
      consuming_fcst_online_    IN BOOLEAN)
   IS
      due_date_                   DATE;
      general_date_               DATE;
      consumption_date_           DATE;
      forecast_lev0_              NUMBER := 0;
      forecast_lev1_              NUMBER := 0;
      consumed_forecast_          NUMBER := 0;
      demand_remainder_           NUMBER := 0;
      forecast_lev0_consumed_     NUMBER := 0;
      forecast_lev1_consumed_     NUMBER := 0;
      part_consume_flag_db_       VARCHAR2(20) := Inventory_Part_API.Get_Forecast_Consump_Flag_Db (contract_, part_no_);
      level_1_forecast_rec_       Level_1_Forecast_API.Public_Rec;
      planned_demand_             NUMBER;
      actual_demand_              NUMBER;
   
      CURSOR back_consume_start_ctr IS
         SELECT MAX(ms_date)
         FROM LEVEL_1_FORECAST_TAB
         WHERE part_no    = part_no_
         AND contract     = contract_
         AND png          = png_
         AND ms_set       = ms_set_
         AND activity_seq = default_supply_activity_
         AND ms_date     <= due_date_
         AND (NVL(forecast_lev0, 0) + NVL(forecast_lev1, 0)) > 0;
   
      CURSOR forward_consume_start_ctr IS
         SELECT MIN(ms_date)
         FROM LEVEL_1_FORECAST_TAB
         WHERE part_no    = part_no_
         AND contract     = contract_
         AND png          = png_
         AND ms_set       = ms_set_
         AND activity_seq = default_supply_activity_
         AND ms_date      > due_date_
         AND fwd_forecast_consumption_ > 0
         AND (NVL(forecast_lev0, 0) + NVL(forecast_lev1, 0)) > 0;
   BEGIN
   
      due_date_ := order_line_due_date_;
   
      -- this is used to keep track of forecast qty remaining to be consumed
      -- on a running basis.
      demand_remainder_ := NVL(order_line_new_qty_, 0) - NVL(order_line_old_qty_, 0);
   
      IF (demand_remainder_ > 0) THEN
   
         -- initial date from which forecasts will be consumed. go backwards in
         -- level_1_forecast starting from due_date_, and get first rec which can
         -- be consumed.
         OPEN back_consume_start_ctr;
         FETCH back_consume_start_ctr INTO consumption_date_;
         CLOSE back_consume_start_ctr;
   
         IF (consumption_date_ IS NOT NULL) THEN
   
            -- initial counter from which forecasts will be consumed. this is incremented
            -- by one so within loop below, call to Level_1_Forecast_API.Get_Prev_Counter_
            -- retrieves correct counter relative to actual demand counter the first time.
            consumption_date_ := consumption_date_ + 1;
   
            -- loop BACKWARDS from due date to consume forecasts.
            WHILE (demand_remainder_ > 0) LOOP
   
               -- get next previous ms date which has non-zero unconsumed forecast.
               general_date_ := Level_1_Forecast_API.Get_Prev_Date_(contract_, part_no_,
                                                                    png_, ms_set_,
                                                                    default_supply_activity_, consumption_date_);
               
               IF (general_date_ IS NULL) THEN
                  EXIT;
               END IF;
   
               -- If a backward consumption boundary exists, then check to see if
               -- this boundary is crossed. If so, write an action message and carry on.
               IF ((Work_Time_Calendar_API.Get_Work_Day_Counter(calendar_id_, due_date_) - Work_Time_Calendar_API.Get_Work_Day_Counter(calendar_id_, general_date_)) > forecast_consumption_wnd_) THEN
                  IF NOT (Level_1_Message_API.Check_Exist_On_Date (
                             contract_          => contract_,
                             part_no_           => part_no_,
                             png_               => png_,
                             ms_set_            => ms_set_,
                             ms_date_           => order_line_due_date_,
                             msg_code_          => 'E530')) THEN                         
   
                     Level_1_Message_API.Batch_New__ (
                        contract_         => contract_,
                        part_no_          => part_no_,
                        png_              => png_,
                        ms_set_           => ms_set_,
                        ms_date_          => order_line_due_date_,
                        order_no_         => NULL,
                        line_no_          => NULL,
                        release_no_       => NULL,
                        line_item_no_     => NULL,
                        order_type_db_    => NULL,
                        activity_seq_     => default_supply_activity_,
                        msg_code_         => 'E530');                     
                  END IF;
               END IF;
   
               -- increment consumption count, this is used to check against
               -- forecast consumption window to insure that if forecasts are
               -- consumed outside this window, an action message is generated.
               consumption_date_ := general_date_;
   
               level_1_forecast_rec_ := Level_1_Forecast_API.Get(contract_, part_no_, png_, ms_set_, default_supply_activity_, consumption_date_);
   
               forecast_lev0_     := NVL(level_1_forecast_rec_.forecast_lev0,     0);
               forecast_lev1_     := NVL(level_1_forecast_rec_.forecast_lev1,     0);
               consumed_forecast_ := NVL(level_1_forecast_rec_.consumed_forecast, 0);
   
               IF ((forecast_lev0_ + forecast_lev1_ - consumed_forecast_) > 0) THEN
   
                  -- initialize forecasts consumed for this rec.
                  forecast_lev0_consumed_ := 0;
                  forecast_lev1_consumed_ := 0;
   
                  -- if qty remaining to be consumed available in forecasts in this rec,
                  -- consume required forecast qty only, else consume total forecasts in
                  -- this rec. forecast_lev1 is first consumed, and then forecast_lev0,
                  -- if needed.
                  IF (demand_remainder_ > (forecast_lev0_ +
                                           forecast_lev1_ -
                                           consumed_forecast_)) THEN
                     forecast_lev1_consumed_ := forecast_lev1_ - consumed_forecast_;
                     forecast_lev0_consumed_ := forecast_lev0_;
                     demand_remainder_       := demand_remainder_ - (forecast_lev1_consumed_ +
                                                                       forecast_lev0_consumed_);
                  ELSE
                     IF (demand_remainder_ > forecast_lev1_ - consumed_forecast_) THEN
                        forecast_lev1_consumed_ := forecast_lev1_    - consumed_forecast_;
                        demand_remainder_       := demand_remainder_ - forecast_lev1_consumed_;
                        forecast_lev0_consumed_ := demand_remainder_;
                        demand_remainder_       := demand_remainder_ - forecast_lev0_consumed_;
                     ELSE
                        forecast_lev1_consumed_ := demand_remainder_;
                        demand_remainder_       := demand_remainder_ - forecast_lev1_consumed_;
                     END IF;
                  END IF;
   
                  -- update level 1 forecast rec with consumed forecast qty.
                  Level_1_Forecast_API.Batch_Modify__ (
                     contract_            => contract_,
                     part_no_             => part_no_,
                     png_                 => png_,
                     ms_set_              => ms_set_,
                     activity_seq_        => default_supply_activity_,
                     ms_date_             => consumption_date_,
                     parent_contract_     => NULL,
                     parent_part_         => NULL,
                     forecast_lev0_       => NULL,
                     forecast_lev1_       => NULL,
                     consumed_forecast_   => forecast_lev1_consumed_ + forecast_lev0_consumed_,
                     actual_demand_       => NULL,
                     planned_demand_      => NULL,
                     supply_              => NULL,
                     consumed_supply_     => NULL,
                     firm_orders_         => NULL,
                     sched_orders_        => NULL,
                     rel_ord_rcpt_        => NULL,
                     master_sched_rcpt_   => NULL,
                     avail_to_prom_       => NULL,
                     roll_up_rcpt_        => NULL,
                     net_avail_           => NULL,
                     proj_avail_          => NULL,
                     mtr_demand_qty_      => NULL,
                     mtr_supply_qty_      => NULL,
                     offset_              => NULL,
                     roll_flag_db_        => NULL,
                     sysgen_flag_         => NULL,
                     master_sched_status_ => NULL,
                     method_              => 'ADD' );
   
               END IF;   -- forecast_lev0_ + forecast_lev1_ - consumed_forecast_ > 0.
   
            END LOOP;   -- BACKWARD consumption while loop.
   
         END IF;   -- consumption counter not null.
         
         IF (demand_remainder_ > 0) THEN
            -- Start FORWARD consumption
            OPEN forward_consume_start_ctr;
            FETCH forward_consume_start_ctr INTO consumption_date_;
            CLOSE forward_consume_start_ctr;
   
            IF (consumption_date_ IS NOT NULL) AND NOT(promise_method_db_ = 'UCF' AND part_consume_flag_db_ = Inv_Part_Forecast_Consum_API.DB_ONLINE_CONSUMPTION) THEN
               consumption_date_ := consumption_date_ - 1;
   
               -- loop forward for consume forecast
               WHILE (demand_remainder_ > 0) LOOP
                  -- get next ms date which has non-zero unconsumed forecast.
                  general_date_ := Level_1_Forecast_API.Get_Next_Date_(contract_, part_no_, png_, ms_set_, default_supply_activity_, consumption_date_);
   
                  IF (general_date_ IS NULL) THEN
                     EXIT;
                  END IF;
   
                  IF (general_date_ - due_date_ <= fwd_forecast_consumption_) THEN
                     -- Should continue only If it is possible to consume from future date.
                     -- Must log a message if possible.
                     IF NOT (Level_1_Message_API.Check_Exist_On_Date (
                                contract_ => contract_,
                                part_no_  => part_no_,
                                png_      => png_,
                                ms_set_   => ms_set_,
                                ms_date_  => order_line_due_date_,
                                msg_code_ => 'E548')) THEN                         
   
                        Level_1_Message_API.Batch_New__ (
                           contract_         => contract_,
                           part_no_          => part_no_,
                           png_              => png_,
                           ms_set_           => ms_set_,
                           ms_date_          => order_line_due_date_,
                           order_no_         => NULL,
                           line_no_          => NULL,
                           release_no_       => NULL,
                           line_item_no_     => NULL,
                           order_type_db_    => NULL,
                           activity_seq_     => default_supply_activity_,
                           msg_code_         => 'E548');                     
                     END IF;
   
                     consumption_date_ := general_date_;
   
                     level_1_forecast_rec_ := Level_1_Forecast_API.Get(contract_, part_no_, png_, ms_set_, default_supply_activity_, consumption_date_);
   
                     forecast_lev0_     := NVL(level_1_forecast_rec_.forecast_lev0,     0);
                     forecast_lev1_     := NVL(level_1_forecast_rec_.forecast_lev1,     0);
                     consumed_forecast_ := NVL(level_1_forecast_rec_.consumed_forecast, 0);
   
                     IF ((forecast_lev0_ + forecast_lev1_ - consumed_forecast_) > 0) THEN
   
                        -- initialize forecasts consumed for this rec.
                        forecast_lev0_consumed_ := 0;
                        forecast_lev1_consumed_ := 0;
   
                        -- if qty remaining to be consumed available in forecasts in this rec,
                        -- consume required forecast qty only, else consume total forecasts in
                        -- this rec. forecast_lev1 is first consumed, and then forecast_lev0,
                        -- if needed.
                        IF (demand_remainder_ > (forecast_lev0_ +
                                                 forecast_lev1_ -
                                                 consumed_forecast_)) THEN
                           forecast_lev1_consumed_ := forecast_lev1_ - consumed_forecast_;
                           forecast_lev0_consumed_ := forecast_lev0_;
                           demand_remainder_       := demand_remainder_ - (forecast_lev1_consumed_ +
                                                                             forecast_lev0_consumed_);
                        ELSE
                           IF (demand_remainder_ > forecast_lev1_ - consumed_forecast_) THEN
                              forecast_lev1_consumed_ := forecast_lev1_    - consumed_forecast_;
                              demand_remainder_       := demand_remainder_ - forecast_lev1_consumed_;
                              forecast_lev0_consumed_ := demand_remainder_;
                              demand_remainder_       := demand_remainder_ - forecast_lev0_consumed_;
                           ELSE
                              forecast_lev1_consumed_ := demand_remainder_;
                              demand_remainder_       := demand_remainder_ - forecast_lev1_consumed_;
                           END IF;
                        END IF;
   
                        -- update level 1 forecast rec with consumed forecast qty.
                        Level_1_Forecast_API.Batch_Modify__ (
                           contract_            => contract_,
                           part_no_             => part_no_,
                           png_                 => png_,
                           ms_set_              => ms_set_,
                           activity_seq_        => default_supply_activity_,
                           ms_date_             => consumption_date_,
                           parent_contract_     => NULL,
                           parent_part_         => NULL,
                           forecast_lev0_       => NULL,
                           forecast_lev1_       => NULL,
                           consumed_forecast_   => forecast_lev1_consumed_ + forecast_lev0_consumed_,
                           actual_demand_       => NULL,
                           planned_demand_      => NULL,
                           supply_              => NULL,
                           consumed_supply_     => NULL,
                           firm_orders_         => NULL,
                           sched_orders_        => NULL,
                           rel_ord_rcpt_        => NULL,
                           master_sched_rcpt_   => NULL,
                           avail_to_prom_       => NULL,
                           roll_up_rcpt_        => NULL,
                           net_avail_           => NULL,
                           proj_avail_          => NULL,
                           mtr_demand_qty_      => NULL,
                           mtr_supply_qty_      => NULL,
                           offset_              => NULL,
                           roll_flag_db_        => NULL,
                           sysgen_flag_         => NULL,
                           master_sched_status_ => NULL,
                           method_              => 'ADD' );
   
                     END IF;   -- forecast_lev0_ + forecast_lev1_ - consumed_forecast_ > 0.
                  ELSE
                     EXIT;
                  END IF;
               END LOOP;
            END IF;  -- Finish FORWARD consumption
         END IF;
   
         -- check to see if actual demand satisfied. if not, insert msg.
         IF (demand_remainder_ > 0) THEN
   
            IF (consuming_fcst_online_ AND source_type_ <> 'SO') THEN
               IF (promise_method_db_ = 'UCF') THEN
                  Error_SYS.Record_General(lu_name_, 'QTYSHORTPOSTATPCHK: Insufficient unconsumed forecast to satisfy actual demand for Site :P1, Part No :P2, and MS Set :P3.',
                                           contract_, part_no_, ms_set_);
               END IF;
            ELSE
               IF NOT (Level_1_Message_API.Check_Exist_On_Date (
                          contract_       => contract_,
                          part_no_        => part_no_,
                          png_            => png_,
                          ms_set_         => ms_set_,
                          ms_date_        => order_line_due_date_,
                          msg_code_       => 'E531')) THEN                       
   
                  Level_1_Message_API.Batch_New__ (
                     contract_      => contract_,
                     part_no_       => part_no_,
                     png_           => png_,
                     ms_set_        => ms_set_,
                     ms_date_       => order_line_due_date_,
                     order_no_      => NULL,
                     line_no_       => NULL,
                     release_no_    => NULL,
                     line_item_no_  => NULL,
                     order_type_db_ => NULL,
                     activity_seq_  => total_demand_activity_,
                     msg_code_      => 'E531');
               END IF;
            END IF;
   
         END IF;
   
      END IF; -- demand_remainder_ > 0.
   
      IF (consuming_fcst_online_) THEN
         -- add/update level_1_forecast rec corresponding to actual demand date.
         IF source_type_ = 'CQ' THEN
            planned_demand_ := NVL(order_line_new_qty_, 0) - NVL(order_line_old_qty_, 0);
            actual_demand_ := 0;
         ELSE
            actual_demand_ := NVL(order_line_new_qty_, 0) - NVL(order_line_old_qty_, 0);
            planned_demand_ := 0;
         END IF;
         
         IF NOT Level_1_Forecast_API.Check_Exist(contract_, part_no_, png_, ms_set_, default_supply_activity_, due_date_) THEN
            
            Level_1_Forecast_API.Batch_New__(
               contract_            => contract_,
               part_no_             => part_no_,
               png_                 => png_,
               ms_set_              => ms_set_,
               activity_seq_        => default_supply_activity_,
               ms_date_             => due_date_,
               parent_contract_     => NULL,
               parent_part_         => NULL,
               forecast_lev0_       => 0,
               forecast_lev1_       => 0,
               consumed_forecast_   => 0,
               actual_demand_       => actual_demand_,
               planned_demand_      => planned_demand_,
               supply_              => 0,
               consumed_supply_     => 0,
               firm_orders_         => 0,
               sched_orders_        => 0,
               rel_ord_rcpt_        => 0,
               master_sched_rcpt_   => 0,
               avail_to_prom_       => 0,
               roll_up_rcpt_        => NULL,
               net_avail_           => 0,
               proj_avail_          => 0,
               mtr_demand_qty_      => 0,
               mtr_supply_qty_      => 0,
               offset_              => NULL,
               sysgen_flag_         => Sysgen_API.Decode(sysgen_yes_),
               master_sched_status_ => Master_Sched_Status_API.Decode(Master_Sched_Status_API.DB_PROPOSED_MS_RECEIPT));
   
         ELSE
   
            Level_1_Forecast_API.Batch_Modify__ (
               contract_            => contract_,
               part_no_             => part_no_,
               png_                 => png_,
               ms_set_              => ms_set_,
               activity_seq_        => default_supply_activity_,
               ms_date_             => due_date_,
               parent_contract_     => NULL,
               parent_part_         => NULL,
               forecast_lev0_       => NULL,
               forecast_lev1_       => NULL,
               consumed_forecast_   => NULL,
               actual_demand_       => actual_demand_,
               planned_demand_      => planned_demand_,
               supply_              => NULL,
               consumed_supply_     => NULL,
               firm_orders_         => NULL,
               sched_orders_        => NULL,
               rel_ord_rcpt_        => NULL,
               master_sched_rcpt_   => NULL,
               avail_to_prom_       => NULL,
               roll_up_rcpt_        => NULL,
               net_avail_           => NULL,
               proj_avail_          => NULL,
               mtr_demand_qty_      => NULL,
               mtr_supply_qty_      => NULL,
               offset_              => NULL,
               roll_flag_db_        => NULL,
               sysgen_flag_         => NULL,
               master_sched_status_ => NULL,
               method_              => 'ADD' );
   
         END IF;
      END IF;
   END Core;

BEGIN
   General_SYS.Init_Method(LEVEL_1_FORECAST_UTIL_API.lu_name_, 'LEVEL_1_FORECAST_UTIL_API', 'Consume_Forecast');
   Core(contract_, part_no_, png_, ms_set_, total_demand_activity_, default_supply_activity_, order_line_new_qty_, order_line_old_qty_, order_line_due_date_, source_type_, promise_method_db_, forecast_consumption_wnd_, fwd_forecast_consumption_, calendar_id_, consuming_fcst_online_);
END Consume_Forecast;


PROCEDURE Consume_Supply (
   contract_                IN VARCHAR2,
   part_no_                 IN VARCHAR2,
   png_                     IN VARCHAR2,
   ms_set_                  IN NUMBER,
   activity_seq_            IN NUMBER,
   order_line_new_qty_      IN NUMBER,
   order_line_old_qty_      IN NUMBER,
   order_line_due_date_     IN DATE,
   promise_method_db_       IN VARCHAR2,
   calendar_id_             IN VARCHAR2,
   consuming_fcst_online_   IN BOOLEAN,
   source_type_             IN VARCHAR2,
   order_line_cancellation_ IN BOOLEAN)
IS
   
   PROCEDURE Core (
      contract_                IN VARCHAR2,
      part_no_                 IN VARCHAR2,
      png_                     IN VARCHAR2,
      ms_set_                  IN NUMBER,
      activity_seq_            IN NUMBER,
      order_line_new_qty_      IN NUMBER,
      order_line_old_qty_      IN NUMBER,
      order_line_due_date_     IN DATE,
      promise_method_db_       IN VARCHAR2,
      calendar_id_             IN VARCHAR2,
      consuming_fcst_online_   IN BOOLEAN,
      source_type_             IN VARCHAR2,
      order_line_cancellation_ IN BOOLEAN)
   IS
      due_date_                   DATE;
      error_info_                 VARCHAR2(200);
      consumption_date_           DATE;
      general_date_               DATE;
      l_activity_seq_             NUMBER := activity_seq_;
      supply_                     NUMBER := 0;
      consumed_supply_            NUMBER := 0;
      actual_demand_remainder_    NUMBER := 0;
      supply_consumed_            NUMBER := 0;
      level_1_forecast_rec_       Level_1_Forecast_API.Public_Rec;
   
      CURSOR back_consume_start_date IS
         SELECT MAX(ms_date)
         FROM LEVEL_1_FORECAST_TAB
         WHERE contract     = contract_
         AND   png          = png_
         AND   part_no      = part_no_
         AND   ms_set       = ms_set_
         AND   ms_date     <= due_date_
         AND   (NVL(supply, 0) - NVL(consumed_supply, 0)) > 0;
   
   BEGIN
      due_date_ := order_line_due_date_;
   
      -- Below code is used to keep track of supply qty remaining to be consumed on a
      -- running basis.
      actual_demand_remainder_ := NVL(order_line_new_qty_, 0) - NVL(order_line_old_qty_, 0);
   
      IF (actual_demand_remainder_ > 0) THEN
   
         -- initial date from which supply will be consumed. go backwards in
         -- level_1_forecast starting from due_date_, and get first rec which can
         -- be consumed.
         OPEN back_consume_start_date;
         FETCH back_consume_start_date INTO consumption_date_;
         CLOSE back_consume_start_date;
   
         IF (consumption_date_ IS NOT NULL) THEN
   
            -- initial counter from which supply will be consumed. this is incremented
            -- by one so within loop below, call to Level_1_Forecast_API.Get_Prev_Supply_Cntr_
            -- retrieves correct counter relative to actual demand counter the first time.
            consumption_date_ := consumption_date_ + 1;
   
            -- loop BACKWARDS from due date to consume supply.
            WHILE (actual_demand_remainder_ > 0) LOOP
   
               -- get next previous date which has non-zero unconsumed supply.
               IF png_ = '*' THEN 
                  general_date_ := Level_1_Forecast_API.Get_Prev_Supply_Date_(contract_, part_no_, png_, ms_set_, l_activity_seq_, consumption_date_);
               ELSE
                  Level_1_Forecast_API.Get_Prev_Supply_Activity_(l_activity_seq_, general_date_, contract_, part_no_, png_, ms_set_, consumption_date_);
               END IF;
   
               IF (general_date_ IS NULL) THEN
                  EXIT;
               END IF;
   
               consumption_date_ := general_date_;
   
               level_1_forecast_rec_ := Level_1_Forecast_API.Get(contract_, part_no_, png_, ms_set_, l_activity_seq_, consumption_date_);
   
               supply_          := NVL(level_1_forecast_rec_.supply,          0);
               consumed_supply_ := NVL(level_1_forecast_rec_.consumed_supply, 0);
   
               IF ((supply_ - consumed_supply_) > 0) THEN
   
                  -- initialize forecasts consumed for this rec.
                  supply_consumed_ := 0;
   
                  -- if qty remaining to be consumed available in supply in this rec,
                  -- consume required supply qty only, else consume total supply in
                  -- this rec.
                  IF (actual_demand_remainder_ > (supply_ - consumed_supply_)) THEN
                     supply_consumed_         := supply_ - consumed_supply_;
                     actual_demand_remainder_ := actual_demand_remainder_ - supply_consumed_;
                  ELSE
                     supply_consumed_         := actual_demand_remainder_;
                     actual_demand_remainder_ := 0;
                  END IF;
   
                  -- update level 1 forecast rec with consumed supply qty.
                  Level_1_Forecast_API.Batch_Modify__ (
                     contract_            => contract_,
                     part_no_             => part_no_,
                     png_                 => png_,
                     ms_set_              => ms_set_,
                     activity_seq_        => l_activity_seq_,
                     ms_date_             => consumption_date_,
                     parent_contract_     => NULL,
                     parent_part_         => NULL,
                     forecast_lev0_       => NULL,
                     forecast_lev1_       => NULL,
                     consumed_forecast_   => NULL,
                     actual_demand_       => NULL,
                     planned_demand_      => NULL,
                     supply_              => NULL,
                     consumed_supply_     => supply_consumed_,
                     firm_orders_         => NULL,
                     sched_orders_        => NULL,
                     rel_ord_rcpt_        => NULL,
                     master_sched_rcpt_   => NULL,
                     avail_to_prom_       => NULL,
                     roll_up_rcpt_        => NULL,
                     net_avail_           => NULL,
                     proj_avail_          => NULL,
                     mtr_demand_qty_      => NULL,
                     mtr_supply_qty_      => NULL,
                     offset_              => NULL,
                     roll_flag_db_        => NULL,
                     sysgen_flag_         => NULL,
                     master_sched_status_ => NULL,
                     method_              => 'ADD' );
   
               END IF; -- supply_ - consumed_supply_ > 0.
   
            END LOOP; -- BACKWARD consumption while loop.
   
         END IF; -- consumption counter not null.
   
         -- check to see if actual demand satisfied. if not, insert msg.
         IF (actual_demand_remainder_ > 0) THEN
            IF (consuming_fcst_online_ AND source_type_ <> 'SO') THEN
               IF (promise_method_db_ = 'ATP' AND NOT order_line_cancellation_) THEN
                  Error_SYS.Record_General(lu_name_, 'QTYSHORTPOSTATPCHK2: Insufficient unconsumed supply to satisfy actual demand for Site :P1, Part No :P2, and MS Set :P3.', contract_, part_no_, ms_set_);
               END IF;
            ELSE
               IF NOT (Level_1_Message_API.Check_Exist_On_Date (
                           contract_      => contract_,
                           part_no_       => part_no_,
                           png_           => png_,
                           ms_set_        => ms_set_,
                           ms_date_       => order_line_due_date_,
                           msg_code_      => 'E532')) THEN                      
   
                  Level_1_Message_API.Batch_New__ (
                     contract_      => contract_,
                     part_no_       => part_no_,
                     png_           => png_,
                     ms_set_        => ms_set_,
                     ms_date_       => order_line_due_date_,
                     order_no_      => NULL,
                     line_no_       => NULL,
                     release_no_    => NULL,
                     line_item_no_  => NULL,
                     order_type_db_ => NULL,
                     activity_seq_  => activity_seq_,
                     msg_code_      => 'E532');
               END IF;
            END IF;
         END IF;
   
      END IF;   -- actual_demand_remainder_ > 0.
   
   EXCEPTION
      WHEN OTHERS THEN
         IF Error_SYS.Is_Foundation_Error(SQLCODE) THEN
            RAISE;
         END IF;
   
         error_info_ := contract_ || '/' || png_ || '/' || part_no_ || '/' || ms_set_;
         Error_Sys.Appl_General (
            lu_name_,
            'CONSUP: Error :P1 occurred while running LEVEL_1_FORECAST_UTIL_API.Consume_Supply for Site/PNG/Part No/Ms Set :P2.',
            SQLERRM,
            error_info_);
   END Core;

BEGIN
   General_SYS.Init_Method(LEVEL_1_FORECAST_UTIL_API.lu_name_, 'LEVEL_1_FORECAST_UTIL_API', 'Consume_Supply');
   Core(contract_, part_no_, png_, ms_set_, activity_seq_, order_line_new_qty_, order_line_old_qty_, order_line_due_date_, promise_method_db_, calendar_id_, consuming_fcst_online_, source_type_, order_line_cancellation_);
END Consume_Supply;


PROCEDURE Update_Consumption (
   contract_                 IN VARCHAR2,
   part_no_                  IN VARCHAR2,
   new_demand_quantity_      IN NUMBER,
   old_demand_quantity_      IN NUMBER,
   new_due_date_             IN DATE,
   old_due_date_             IN DATE)
IS
   
   PROCEDURE Core (
      contract_                 IN VARCHAR2,
      part_no_                  IN VARCHAR2,
      new_demand_quantity_      IN NUMBER,
      old_demand_quantity_      IN NUMBER,
      new_due_date_             IN DATE,
      old_due_date_             IN DATE)
   IS
      result_code_              VARCHAR2(2000) := 'SUCCESS';
      available_qty_            NUMBER;
      earliest_available_date_  DATE;
   BEGIN
      IF (Level_1_Part_API.Check_Exist (contract_, part_no_, '*') AND Level_1_Part_API.Check_Active (contract_, part_no_, '*') = 1) THEN
         Control_Consumption(
            result_code_               => result_code_,
            available_qty_             => available_qty_,
            earliest_available_date_   => earliest_available_date_,
            contract_                  => contract_,
            part_no_                   => part_no_,
            new_demand_qty_            => new_demand_quantity_,
            old_demand_qty_            => old_demand_quantity_,
            new_due_date_              => new_due_date_,
            old_due_date_              => old_due_date_,
            source_type_               => 'SO',
            order_line_cancellation_   => FALSE);
      END IF;
      IF (result_code_ != 'SUCCESS') THEN
         Error_SYS.Appl_General(lu_name_, result_code_);
      END IF;
   END Core;

BEGIN
   General_SYS.Init_Method(LEVEL_1_FORECAST_UTIL_API.lu_name_, 'LEVEL_1_FORECAST_UTIL_API', 'Update_Consumption');
   Core(contract_, part_no_, new_demand_quantity_, old_demand_quantity_, new_due_date_, old_due_date_);
END Update_Consumption;


PROCEDURE Unconsume_Forecast (
   contract_                  IN VARCHAR2,
   part_no_                   IN VARCHAR2,
   png_                       IN VARCHAR2,
   ms_set_                    IN NUMBER,
   ms_receipt_activity_seq_   IN NUMBER,
   new_demand_qty_            IN NUMBER,
   old_demand_qty_            IN NUMBER,
   new_due_date_              IN DATE,
   old_due_date_              IN DATE,
   source_type_               IN VARCHAR2,
   promise_method_db_         IN VARCHAR2,
   calendar_id_               IN VARCHAR2,
   forecast_consumption_wnd_  IN NUMBER,
   fwd_forecast_consumption_  IN NUMBER )
IS
   
   PROCEDURE Core (
      contract_                  IN VARCHAR2,
      part_no_                   IN VARCHAR2,
      png_                       IN VARCHAR2,
      ms_set_                    IN NUMBER,
      ms_receipt_activity_seq_   IN NUMBER,
      new_demand_qty_            IN NUMBER,
      old_demand_qty_            IN NUMBER,
      new_due_date_              IN DATE,
      old_due_date_              IN DATE,
      source_type_               IN VARCHAR2,
      promise_method_db_         IN VARCHAR2,
      calendar_id_               IN VARCHAR2,
      forecast_consumption_wnd_  IN NUMBER,
      fwd_forecast_consumption_  IN NUMBER )
   IS
      local_contract_   VARCHAR2(200);
      planned_demand_   NUMBER;
      actual_demand_    NUMBER;
   
      CURSOR init_consumed_forecast IS
         SELECT ms_date
         FROM LEVEL_1_FORECAST_TAB
         WHERE contract = contract_
         AND   part_no  = part_no_
         AND   png      = png_
         AND   ms_set   = ms_set_;
   
   BEGIN
   
      IF NOT Level_1_Forecast_API.Check_Exist(contract_, part_no_, '*', ms_set_, 0, TRUNC(new_due_date_)) THEN
         IF source_type_ = 'CQ' THEN
            planned_demand_ := NVL(new_demand_qty_, 0);
            actual_demand_ := 0;
         ELSE
            actual_demand_ := NVL(new_demand_qty_, 0);
            planned_demand_ := 0;
         END IF;
            
         Level_1_Forecast_API.Batch_New__(
            contract_            => contract_,
            part_no_             => part_no_,
            png_                 => png_,
            ms_set_              => ms_set_,
            activity_seq_        => 0,
            ms_date_             => TRUNC(new_due_date_),
            parent_contract_     => NULL,
            parent_part_         => NULL,
            forecast_lev0_       => 0,
            forecast_lev1_       => 0,
            consumed_forecast_   => 0,
            actual_demand_       => actual_demand_,
            planned_demand_      => planned_demand_,
            supply_              => 0,
            consumed_supply_     => 0,
            firm_orders_         => 0,
            sched_orders_        => 0,
            rel_ord_rcpt_        => 0,
            master_sched_rcpt_   => 0,
            avail_to_prom_       => 0,
            roll_up_rcpt_        => NULL,
            net_avail_           => 0,
            proj_avail_          => 0,
            mtr_demand_qty_      => 0,
            mtr_supply_qty_      => 0,
            offset_              => NULL,
            sysgen_flag_         => Sysgen_API.Decode(sysgen_yes_),
            master_sched_status_ => Master_Sched_Status_API.Decode(Master_Sched_Status_API.DB_PROPOSED_MS_RECEIPT));
      ELSE
         IF source_type_ = 'CQ' THEN
            planned_demand_ := NVL(new_demand_qty_, 0) - NVL(old_demand_qty_, 0);
            actual_demand_ := NULL;
         ELSE
            actual_demand_ := NVL(new_demand_qty_, 0) - NVL(old_demand_qty_, 0);
            planned_demand_ := NULL;
         END IF;
         
         Level_1_Forecast_API.Batch_Modify__ (
            contract_            => contract_,
            part_no_             => part_no_,
            png_                 => png_,
            ms_set_              => ms_set_,
            activity_seq_        => 0,
            ms_date_             => TRUNC(new_due_date_),
            parent_contract_     => NULL,
            parent_part_         => NULL,
            forecast_lev0_       => NULL,
            forecast_lev1_       => NULL,
            consumed_forecast_   => NULL,
            actual_demand_       => actual_demand_,
            planned_demand_      => planned_demand_,
            supply_              => NULL,
            consumed_supply_     => NULL,
            firm_orders_         => NULL,
            sched_orders_        => NULL,
            rel_ord_rcpt_        => NULL,
            master_sched_rcpt_   => NULL,
            avail_to_prom_       => NULL,
            roll_up_rcpt_        => NULL,
            net_avail_           => NULL,
            proj_avail_          => NULL,
            mtr_demand_qty_      => NULL,
            mtr_supply_qty_      => NULL,
            offset_              => NULL,
            roll_flag_db_        => NULL,
            sysgen_flag_         => NULL,
            master_sched_status_ => NULL,
            method_              => 'ADD' );
      END IF;
   
      -- Initialize consumed forecast.
      FOR init_consumed_forecast_rec IN init_consumed_forecast LOOP
   
         Level_1_Forecast_API.Batch_Modify__ (
            contract_            => contract_,
            part_no_             => part_no_,
            png_                 => png_,
            ms_set_              => ms_set_,
            activity_seq_        => 0,
            ms_date_             => init_consumed_forecast_rec.ms_date,
            parent_contract_     => NULL,
            parent_part_         => NULL,
            forecast_lev0_       => NULL,
            forecast_lev1_       => NULL,
            consumed_forecast_   => 0,
            actual_demand_       => NULL,
            planned_demand_      => NULL,
            supply_              => NULL,
            consumed_supply_     => NULL,
            firm_orders_         => NULL,
            sched_orders_        => NULL,
            rel_ord_rcpt_        => NULL,
            master_sched_rcpt_   => NULL,
            avail_to_prom_       => NULL,
            roll_up_rcpt_        => NULL,
            net_avail_           => NULL,
            proj_avail_          => NULL,
            mtr_demand_qty_      => NULL,
            mtr_supply_qty_      => NULL,
            offset_              => NULL,
            roll_flag_db_        => NULL,
            sysgen_flag_         => NULL,
            master_sched_status_ => NULL,
            method_              => 'UPDATE' );
   
      END LOOP;
   
      -- Recalculate consumed forecast.
      -- level1forecast record will be updated once Consume_Forecast() is executed down the line
      Recalc_Consumed_Fcst__ (contract_, part_no_, png_, ms_set_, ms_receipt_activity_seq_, FALSE, source_type_, promise_method_db_, calendar_id_,
                              forecast_consumption_wnd_, fwd_forecast_consumption_ );
   
   EXCEPTION
      WHEN OTHERS THEN
         IF Error_SYS.Is_Foundation_Error(SQLCODE) THEN
            RAISE;
         END IF;
   
         local_contract_ := contract_ || ', Part No ' || part_no_;
   
         Error_Sys.Appl_General (lu_name_, 'UNCONSUME: Error :P1 occurred while running LEVEL_1_FORECAST_UTIL_API.Unconsume_Forecast for Site :P2 MS Set :P3.', SQLERRM, local_contract_, ms_set_);
   END Core;

BEGIN
   General_SYS.Init_Method(LEVEL_1_FORECAST_UTIL_API.lu_name_, 'LEVEL_1_FORECAST_UTIL_API', 'Unconsume_Forecast');
   Core(contract_, part_no_, png_, ms_set_, ms_receipt_activity_seq_, new_demand_qty_, old_demand_qty_, new_due_date_, old_due_date_, source_type_, promise_method_db_, calendar_id_, forecast_consumption_wnd_, fwd_forecast_consumption_);
END Unconsume_Forecast;


PROCEDURE Unconsume_Supply (
   contract_                IN VARCHAR2,
   part_no_                 IN VARCHAR2,
   png_                     IN VARCHAR2,
   ms_set_                  IN NUMBER,
   new_demand_qty_          IN NUMBER,
   old_demand_qty_          IN NUMBER,
   new_due_date_            IN DATE,
   old_due_date_            IN DATE,
   consuming_fcst_online_   IN BOOLEAN,
   source_type_             IN VARCHAR2,
   promise_method_db_       IN VARCHAR2,
   calendar_id_             IN VARCHAR2,
   order_line_cancellation_ IN BOOLEAN )
IS
   
   PROCEDURE Core (
      contract_                IN VARCHAR2,
      part_no_                 IN VARCHAR2,
      png_                     IN VARCHAR2,
      ms_set_                  IN NUMBER,
      new_demand_qty_          IN NUMBER,
      old_demand_qty_          IN NUMBER,
      new_due_date_            IN DATE,
      old_due_date_            IN DATE,
      consuming_fcst_online_   IN BOOLEAN,
      source_type_             IN VARCHAR2,
      promise_method_db_       IN VARCHAR2,
      calendar_id_             IN VARCHAR2,
      order_line_cancellation_ IN BOOLEAN )
   IS
      local_contract_   VARCHAR2(200);
      planned_demand_   NUMBER;
      actual_demand_    NUMBER;
   
      CURSOR init_consumed_forecast IS
         SELECT ms_date
         FROM LEVEL_1_FORECAST_TAB
         WHERE contract = contract_
         AND   part_no  = part_no_
         AND   png      = png_
         AND   ms_set   = ms_set_;
   
   BEGIN
   
      IF NOT Level_1_Forecast_API.Check_Exist(contract_, part_no_, '*', ms_set_, 0, TRUNC(new_due_date_)) THEN
         IF source_type_ = 'CQ' THEN
            planned_demand_ := NVL(new_demand_qty_, 0);
            actual_demand_ := 0;
         ELSE
            actual_demand_ := NVL(new_demand_qty_, 0);
            planned_demand_ := 0;
         END IF;
         
         Level_1_Forecast_API.Batch_New__(
            contract_            => contract_,
            part_no_             => part_no_,
            png_                 => png_,
            ms_set_              => ms_set_,
            activity_seq_        => 0,
            ms_date_             => TRUNC(new_due_date_),
            parent_contract_     => NULL,
            parent_part_         => NULL,
            forecast_lev0_       => 0,
            forecast_lev1_       => 0,
            consumed_forecast_   => 0,
            actual_demand_       => actual_demand_,
            planned_demand_      => planned_demand_,
            supply_              => 0,
            consumed_supply_     => 0,
            firm_orders_         => 0,
            sched_orders_        => 0,
            rel_ord_rcpt_        => 0,
            master_sched_rcpt_   => 0,
            avail_to_prom_       => 0,
            roll_up_rcpt_        => NULL,
            net_avail_           => 0,
            proj_avail_          => 0,
            mtr_demand_qty_      => 0,
            mtr_supply_qty_      => 0,
            offset_              => NULL,
            sysgen_flag_         => Sysgen_API.Decode(sysgen_yes_),
            master_sched_status_ => Master_Sched_Status_API.Decode(Master_Sched_Status_API.DB_PROPOSED_MS_RECEIPT));
      END IF;
   
      -- initialize consumed supply.
      FOR init_consumed_forecast_rec IN init_consumed_forecast LOOP
   
         Level_1_Forecast_API.Batch_Modify__ (
            contract_            => contract_,
            part_no_             => part_no_,
            png_                 => png_,
            ms_set_              => ms_set_,
            activity_seq_        => 0,
            ms_date_             => init_consumed_forecast_rec.ms_date,
            parent_contract_     => NULL,
            parent_part_         => NULL,
            forecast_lev0_       => NULL,
            forecast_lev1_       => NULL,
            consumed_forecast_   => NULL,
            actual_demand_       => NULL,
            planned_demand_      => NULL,
            supply_              => NULL,
            consumed_supply_     => 0,
            firm_orders_         => NULL,
            sched_orders_        => NULL,
            rel_ord_rcpt_        => NULL,
            master_sched_rcpt_   => NULL,
            avail_to_prom_       => NULL,
            roll_up_rcpt_        => NULL,
            net_avail_           => NULL,
            proj_avail_          => NULL,
            mtr_demand_qty_      => NULL,
            mtr_supply_qty_      => NULL,
            offset_              => NULL,
            roll_flag_db_        => NULL,
            sysgen_flag_         => NULL,
            master_sched_status_ => NULL,
            method_              => 'UPDATE' );
   
      END LOOP;
      
      IF NOT consuming_fcst_online_ THEN
         -- Remove message: Insufficient unconsumed Supply to satisfy Actual Demand
         Level_1_Message_API.Remove_Site_Part_Msg_Code__(contract_, part_no_, png_, ms_set_, 'E532');
      END IF;
   
      -- Recalculate consumed supply.
      Recalc_Consumed_Supply__ (contract_, part_no_, png_, ms_set_, consuming_fcst_online_, source_type_, promise_method_db_, calendar_id_, order_line_cancellation_);
   
   EXCEPTION
      WHEN OTHERS THEN
         IF Error_SYS.Is_Foundation_Error(SQLCODE) THEN
            RAISE;
         END IF;
   
         local_contract_ := contract_ || ', Part No ' || part_no_;
   
         Error_Sys.Appl_General (lu_name_, 'UNCONSUP: Error :P1 occurred while running LEVEL_1_FORECAST_UTIL_API.Unconsume_Supply for Site :P2 MS Set :P3.', SQLERRM, local_contract_, ms_set_);
   END Core;

BEGIN
   General_SYS.Init_Method(LEVEL_1_FORECAST_UTIL_API.lu_name_, 'LEVEL_1_FORECAST_UTIL_API', 'Unconsume_Supply');
   Core(contract_, part_no_, png_, ms_set_, new_demand_qty_, old_demand_qty_, new_due_date_, old_due_date_, consuming_fcst_online_, source_type_, promise_method_db_, calendar_id_, order_line_cancellation_);
END Unconsume_Supply;


PROCEDURE Update_Family_Info (
   contract_   IN VARCHAR2,
   part_no_    IN VARCHAR2,
   png_        IN VARCHAR2,
   ms_set_     IN NUMBER )
IS
   
   PROCEDURE Core (
      contract_   IN VARCHAR2,
      part_no_    IN VARCHAR2,
      png_        IN VARCHAR2,
      ms_set_     IN NUMBER )
   IS
      level_1_part_rec_  Level_1_Part_API.Public_Rec := Level_1_Part_API.Get(contract_, part_no_, png_);
   
         CURSOR family_info_update IS
         SELECT contract, part_no, png, activity_seq, ms_date 
         FROM LEVEL_1_FORECAST_TAB
         WHERE contract = contract_
         AND   part_no  = part_no_
         AND   png      = png_
         AND   ms_set   = ms_set_;
   
   BEGIN
   
      FOR cursor_rec IN family_info_update LOOP
         Level_1_Forecast_API.Batch_Modify__ (
            contract_            => cursor_rec.contract,
            part_no_             => cursor_rec.part_no,
            png_                 => cursor_rec.png,
            ms_set_              => ms_set_,
            activity_seq_        => cursor_rec.activity_seq,
            ms_date_             => cursor_rec.ms_date,
            parent_contract_     => NVL(level_1_part_rec_.parent_contract, 'MAKE NULL'),
            parent_part_         => NVL(level_1_part_rec_.parent_part_no,  'MAKE NULL'),
            forecast_lev0_       => NULL,
            forecast_lev1_       => NULL,
            consumed_forecast_   => NULL,
            actual_demand_       => NULL,
            planned_demand_      => NULL,
            supply_              => NULL,
            consumed_supply_     => NULL,
            firm_orders_         => NULL,
            sched_orders_        => NULL,
            rel_ord_rcpt_        => NULL,
            master_sched_rcpt_   => NULL,
            avail_to_prom_       => NULL,
            roll_up_rcpt_        => NULL,
            net_avail_           => NULL,
            proj_avail_          => NULL,
            mtr_demand_qty_      => NULL,
            mtr_supply_qty_      => NULL,
            offset_              => NULL,
            roll_flag_db_        => NULL,
            sysgen_flag_         => NULL,
            master_sched_status_ => NULL,
            method_              => 'UPDATE' );
      END LOOP;
   
   END Core;

BEGIN
   General_SYS.Init_Method(LEVEL_1_FORECAST_UTIL_API.lu_name_, 'LEVEL_1_FORECAST_UTIL_API', 'Update_Family_Info');
   Core(contract_, part_no_, png_, ms_set_);
END Update_Family_Info;


--@IgnoreMissingSysinit
FUNCTION Get_Sum_Of_Forecast (
   contract_  IN VARCHAR2,
   part_no_   IN VARCHAR2,
   png_       IN VARCHAR2,
   ms_set_    IN NUMBER,
   from_date_ IN DATE,
   to_date_   IN DATE ) RETURN NUMBER
IS
   
   FUNCTION Core (
      contract_  IN VARCHAR2,
      part_no_   IN VARCHAR2,
      png_       IN VARCHAR2,
      ms_set_    IN NUMBER,
      from_date_ IN DATE,
      to_date_   IN DATE ) RETURN NUMBER
   IS
      total_forecast_ LEVEL_1_FORECAST.forecast_lev0%TYPE;
   
      CURSOR get_total IS
         SELECT SUM(NVL(forecast_lev0,0) + NVL(forecast_lev1,0))
         FROM LEVEL_1_FORECAST_TAB
         WHERE contract = contract_
         AND   part_no  = part_no_
         AND    png     = png_
         AND   ms_set   = ms_set_
         AND   ms_date BETWEEN  NVL(from_date_,TRUNC(sysdate))
               AND  NVL(to_date_,ms_date);
   
   BEGIN
   
      OPEN get_total;
      FETCH get_total INTO total_forecast_;
      CLOSE get_total;
      IF (total_forecast_ IS NULL) THEN
         total_forecast_ := 0;
      END IF;
      RETURN total_forecast_;
   
   END Core;

BEGIN
   RETURN Core(contract_, part_no_, png_, ms_set_, from_date_, to_date_);
END Get_Sum_Of_Forecast;


--@IgnoreMissingSysinit
FUNCTION Get_Last_Forecast_Date (
   contract_  IN VARCHAR2,
   part_no_   IN VARCHAR2,
   png_       IN VARCHAR2,
   ms_set_    IN NUMBER,
   from_date_ IN DATE,
   to_date_   IN DATE ) RETURN DATE
IS
   
   FUNCTION Core (
      contract_  IN VARCHAR2,
      part_no_   IN VARCHAR2,
      png_       IN VARCHAR2,
      ms_set_    IN NUMBER,
      from_date_ IN DATE,
      to_date_   IN DATE ) RETURN DATE
   IS
      last_ms_date_ LEVEL_1_FORECAST.ms_date%TYPE;
   
      CURSOR get_last_ms_date IS
         SELECT MAX(ms_date)
         FROM LEVEL_1_FORECAST
         WHERE contract = contract_
         AND   part_no  = part_no_
         AND   png      = png_
         AND   ms_set   = ms_set_
         AND   ms_date BETWEEN  NVL(from_date_,TRUNC(sysdate))
               AND  NVL(to_date_,ms_date);
   
   BEGIN
   
      OPEN  get_last_ms_date;
      FETCH get_last_ms_date INTO last_ms_date_;
      CLOSE get_last_ms_date;
      RETURN last_ms_date_;
   
   END Core;

BEGIN
   RETURN Core(contract_, part_no_, png_, ms_set_, from_date_, to_date_);
END Get_Last_Forecast_Date;


--@IgnoreMissingSysinit
FUNCTION Get_Sum_Forecast_Lev0 (
   contract_  IN VARCHAR2,
   part_no_   IN VARCHAR2,
   png_       IN VARCHAR2,
   ms_set_    IN NUMBER ) RETURN NUMBER
IS
   
   FUNCTION Core (
      contract_  IN VARCHAR2,
      part_no_   IN VARCHAR2,
      png_       IN VARCHAR2,
      ms_set_    IN NUMBER ) RETURN NUMBER
   IS
      forecast_lev0_ LEVEL_1_FORECAST.forecast_lev0%TYPE;
      reference_date_ DATE;
   
      CURSOR get_total IS
         SELECT SUM(forecast_lev0)
         FROM LEVEL_1_FORECAST_TAB
         WHERE contract = contract_
         AND   part_no  = part_no_
         AND   png      = png_
         AND   ms_set   = ms_set_
         AND   ms_date >= reference_date_
         AND   forecast_lev0 > 0;
   BEGIN
      reference_date_ := Level_1_Part_By_Ms_Set_API.Get_Reference_Date(contract_, part_no_, '*', ms_set_);
      OPEN get_total;
      FETCH get_total INTO forecast_lev0_;
      CLOSE get_total;
      IF (forecast_lev0_ IS NULL) THEN
         forecast_lev0_ := 0;
      END IF;
      RETURN forecast_lev0_;
   END Core;

BEGIN
   RETURN Core(contract_, part_no_, png_, ms_set_);
END Get_Sum_Forecast_Lev0;


--@IgnoreMissingSysinit
FUNCTION Get_Sum_Forecast_Lev1 (
   contract_  IN VARCHAR2,
   part_no_   IN VARCHAR2,
   png_       IN VARCHAR2,
   ms_set_    IN NUMBER ) RETURN NUMBER
IS
   
   FUNCTION Core (
      contract_  IN VARCHAR2,
      part_no_   IN VARCHAR2,
      png_       IN VARCHAR2,
      ms_set_    IN NUMBER ) RETURN NUMBER
   IS
      forecast_lev1_ LEVEL_1_FORECAST.forecast_lev1%TYPE;
      reference_date_ DATE;
   
      CURSOR get_total IS
         SELECT SUM(forecast_lev1)
         FROM LEVEL_1_FORECAST_TAB
         WHERE contract = contract_
         AND   part_no  = part_no_
         AND   png      = png_
         AND   ms_set   = ms_set_
         AND   ms_date >= reference_date_
         AND   forecast_lev1 > 0;
   BEGIN
      reference_date_ := Level_1_Part_By_Ms_Set_API.Get_Reference_Date(contract_, part_no_, png_, ms_set_);
      OPEN get_total;
      FETCH get_total INTO forecast_lev1_;
      CLOSE get_total;
      IF (forecast_lev1_ IS NULL) THEN
         forecast_lev1_ := 0;
      END IF;
      RETURN forecast_lev1_;
   END Core;

BEGIN
   RETURN Core(contract_, part_no_, png_, ms_set_);
END Get_Sum_Forecast_Lev1;


--@IgnoreMissingSysinit
FUNCTION Get_Sum_Master_Sched_Rcpt (
   contract_  IN VARCHAR2,
   part_no_   IN VARCHAR2,
   png_       IN VARCHAR2,
   ms_set_    IN NUMBER ) RETURN NUMBER
IS
   
   FUNCTION Core (
      contract_  IN VARCHAR2,
      part_no_   IN VARCHAR2,
      png_       IN VARCHAR2,
      ms_set_    IN NUMBER ) RETURN NUMBER
   IS
      master_sched_rcpt_ LEVEL_1_FORECAST.master_sched_rcpt%TYPE;
      reference_date_ DATE;
   
      CURSOR get_total IS
         SELECT SUM(master_sched_rcpt)
         FROM LEVEL_1_FORECAST_TAB
         WHERE contract = contract_
         AND   part_no  = part_no_
         AND   png     = png_
         AND   ms_set   = ms_set_
         AND   ms_date >= reference_date_
         AND   master_sched_rcpt > 0;
   BEGIN
      reference_date_ := Level_1_Part_By_Ms_Set_API.Get_Reference_Date(contract_, part_no_, png_, ms_set_);
      OPEN get_total;
      FETCH get_total INTO master_sched_rcpt_;
      CLOSE get_total;
      IF (master_sched_rcpt_ IS NULL) THEN
         master_sched_rcpt_ := 0;
      END IF;
      RETURN master_sched_rcpt_;
   END Core;

BEGIN
   RETURN Core(contract_, part_no_, png_, ms_set_);
END Get_Sum_Master_Sched_Rcpt;


PROCEDURE Copy_Forecast (
   contract_      IN VARCHAR2,
   part_no_       IN VARCHAR2,
   png_           IN VARCHAR2,
   from_ms_set_   IN NUMBER,
   to_ms_set_     IN NUMBER,
   start_date_    IN DATE,
   copy_lev0_     IN NUMBER,
   copy_lev1_     IN NUMBER )
IS
   
   PROCEDURE Core (
      contract_      IN VARCHAR2,
      part_no_       IN VARCHAR2,
      png_           IN VARCHAR2,
      from_ms_set_   IN NUMBER,
      to_ms_set_     IN NUMBER,
      start_date_    IN DATE,
      copy_lev0_     IN NUMBER,
      copy_lev1_     IN NUMBER )
   IS
      local_contract_   LEVEL_1_FORECAST.contract%TYPE;
      local_part_no_    LEVEL_1_FORECAST.part_no%TYPE;
      local_png_        LEVEL_1_FORECAST.png%TYPE;
      ms_date_          LEVEL_1_FORECAST.ms_date%TYPE;
      forecast_lev0_    LEVEL_1_FORECAST.forecast_lev0%TYPE;
      forecast_lev1_    LEVEL_1_FORECAST.forecast_lev1%TYPE;
      objid_            LEVEL_1_FORECAST.objid%TYPE;
      objversion_       VARCHAR2(2000);
      info_             VARCHAR2(2000);
      attr_             VARCHAR2(2000);
      do_reset_         BOOLEAN := TRUE;
      sysgen_yes_client_   VARCHAR2(200) := Sysgen_API.Get_Client_Value(0);
      prop_ms_rcpt_client_ VARCHAR2(200) := Master_Sched_Status_API.Get_Client_Value(0);
   
      CURSOR get_forecast IS
         SELECT contract, part_no, png, ms_date, activity_seq,
                NVL(forecast_lev0, 0) forecast_lev0, NVL(forecast_lev1, 0) forecast_lev1
         FROM LEVEL_1_FORECAST_TAB
         WHERE contract LIKE contract_
         AND   part_no  LIKE part_no_
         AND   png      LIKE png_
         AND   ms_set     = from_ms_set_
         AND   ms_date   >= TRUNC(start_date_)
         AND   ms_date   >  TRUNC(Level_1_Part_API.Get_Demand_Tf_Date (contract_,
                                                                          part_no,
                                                                          png,
                                                                          ms_set))
         AND   ms_date > TRUNC(SYSDATE)
         AND   (NVL(forecast_lev0,0) > 0 OR
                NVL(forecast_lev1,0) > 0)
         ORDER BY contract, part_no, ms_date;
   
      CURSOR get_obj(activity_seq_ NUMBER) IS
         SELECT objid,
                objversion
         FROM LEVEL_1_FORECAST
         WHERE contract = local_contract_
         AND   part_no  = local_part_no_
         AND   png      = local_png_
         AND   ms_set   = to_ms_set_
         AND   ms_date  = ms_date_
         AND   activity_seq = activity_seq_;
   
   BEGIN
   
      -- check whether user has access to site
      IF (contract_ IS NOT NULL AND contract_ != '%') THEN
         User_Allowed_Site_API.Exist(Fnd_Session_API.Get_Fnd_User, contract_);
      END IF;
   
      -- Validate MS set
      IF to_ms_set_ IS NULL THEN
         Error_Sys.Appl_General(lu_name_, 'MSSETISNULL1: MS Set must have a value');   
      ELSE
         Master_Sched_Set_API.Exist(to_ms_set_);
      END IF;
   
      -- Check if level 0 or level 1 processes are running first.
      IF (Level_1_Part_Util_API.Is_Level_One_Running (
             contract_     => contract_,
             part_no_      => NULL,
             png_          => NULL,
             ms_set_       => from_ms_set_ ) = 1) THEN
         Error_Sys.Appl_General(lu_name_, 'LEV1ORIGINISRUNNING: Level 1 is currently running on the origin MS Set :P1 Site :P2.', from_ms_set_, contract_);
      END IF;
   
      IF (Level_1_Part_Util_API.Is_Level_One_Running (
             contract_     => contract_,
             part_no_      => NULL,
             png_          => NULL,
             ms_set_       => to_ms_set_ ) = 1) THEN
         Error_Sys.Appl_General(lu_name_, 'LEV1DESTISRUNNING: Level 1 is currently running on the destination MS Set :P1 Site :P2.', to_ms_set_, contract_);
      END IF;
   
      FOR rec IN get_forecast LOOP
   
         IF (local_part_no_ = rec.part_no AND local_png_ = rec.png)THEN
            do_reset_ := FALSE;
         ELSE
            local_part_no_  :=  rec.part_no;
            local_png_      :=  rec.png;
         END IF;
   
         local_contract_ :=  rec.contract;
         ms_date_        :=  rec.ms_date;
   
         IF do_reset_ THEN
            Level_1_Forecast_Util_API.Reset_Forecast (
               contract_,
               local_part_no_,
               local_png_,
               to_ms_set_,
               start_date_,
               copy_lev0_,
               copy_lev1_ );
         END IF;
   
         Client_SYS.Clear_Attr(attr_);
   
         IF (NOT Level_1_Part_By_Ms_Set_API.Check_Exist (
                    rec.contract,
                    rec.part_no,
                    rec.png, 
                    to_ms_set_)) THEN
   
            Level_1_Part_By_Ms_Set_API.Batch_New__ (
               rec.contract,
               rec.part_no,
               rec.png,  
               to_ms_set_,
               TRUNC(Level_1_Part_By_Ms_Set_API.Get_Last_Run_Date (local_contract_,
                                                                  local_part_no_,
                                                                  local_png_,  
                                                                  from_ms_set_)));
   
         END IF;
   
         IF (Level_1_Forecast_API.Check_Exist (
                rec.contract,
                rec.part_no,
                rec.png,
                to_ms_set_,
                rec.activity_seq,
                rec.ms_date ) = TRUE) THEN
   
            IF (copy_lev0_ = 1) THEN
               forecast_lev0_ := NVL(rec.forecast_lev0,0);
               Client_SYS.Add_To_Attr ('FORECAST_LEV0', forecast_lev0_, attr_);
            END IF;
   
            IF (copy_lev1_ = 1) THEN
               forecast_lev1_ := NVL(rec.forecast_lev1,0);
               Client_SYS.Add_To_Attr ('FORECAST_LEV1', forecast_lev1_, attr_);
            END IF;
   
            OPEN  get_obj(rec.activity_seq);
            FETCH get_obj INTO objid_, objversion_;
            CLOSE get_obj;
   
            Level_1_Forecast_API.Modify__ (info_, objid_, objversion_, attr_,'DO');
   
         ELSE
   
            Client_SYS.Add_To_Attr ('CONTRACT', local_contract_, attr_);
            Client_SYS.Add_To_Attr ('PART_NO', local_part_no_, attr_);
            Client_SYS.Add_To_Attr ('PNG', local_png_, attr_);
            Client_SYS.Add_To_Attr ('MS_SET', to_ms_set_, attr_);
            Client_SYS.Add_To_Attr ('MS_DATE', rec.ms_date, attr_);
            Client_SYS.Add_To_Attr ('ACTIVITY_SEQ', rec.activity_seq, attr_);
            Client_SYS.Add_To_Attr ('MASTER_SCHED_RCPT', 0, attr_);
            Client_SYS.Add_To_Attr ('SYSGEN_FLAG', sysgen_yes_client_, attr_);
            Client_SYS.Add_To_Attr ('MASTER_SCHED_STATUS', prop_ms_rcpt_client_, attr_);
   
            IF (copy_lev0_ = 1) THEN
               Client_SYS.Add_To_Attr ('FORECAST_LEV0', rec.forecast_lev0, attr_);
            END IF;
   
            IF (copy_lev1_ = 1) THEN
               Client_SYS.Add_To_Attr ('FORECAST_LEV1', rec.forecast_lev1, attr_);
            END IF;
   
            IF ( (copy_lev0_ = 1 AND nvl(rec.forecast_lev0, 0) > 0) OR (copy_lev1_ = 1 AND nvl(rec.forecast_lev1, 0) > 0) ) THEN
               Level_1_Forecast_API.New__ (info_, objid_, objversion_, attr_, 'DO');
            END IF;
         END IF;
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         IF Error_SYS.Is_Foundation_Error(SQLCODE) THEN
            RAISE;
         END IF;
   
         Error_Sys.Appl_General (lu_name_, 'COPYFCST: Error :P1 occurred while running LEVEL_1_FORECAST_UTIL_API.Copy_Forecast for Site :P2 Part No :P3.', SQLERRM, contract_, part_no_);
   END Core;

BEGIN
   General_SYS.Init_Method(LEVEL_1_FORECAST_UTIL_API.lu_name_, 'LEVEL_1_FORECAST_UTIL_API', 'Copy_Forecast');
   Core(contract_, part_no_, png_, from_ms_set_, to_ms_set_, start_date_, copy_lev0_, copy_lev1_);
END Copy_Forecast;


PROCEDURE Copy_Entire_Master_Schedule(
   contract_      IN VARCHAR2,
   from_ms_set_   IN NUMBER,
   to_ms_set_     IN NUMBER,
   part_no_       IN VARCHAR2,
   png_           IN VARCHAR2)
IS
   
   PROCEDURE Core(
      contract_      IN VARCHAR2,
      from_ms_set_   IN NUMBER,
      to_ms_set_     IN NUMBER,
      part_no_       IN VARCHAR2,
      png_           IN VARCHAR2)
   IS
      local_part_no_    LEVEL_1_FORECAST_TAB.part_no%TYPE := NVL(part_no_,'%');
      local_png_        LEVEL_1_FORECAST_TAB.png%TYPE := NVL(png_,'%');
      info_             VARCHAR2(2000);
      objid_            VARCHAR2(20);
      objversion_       VARCHAR2(200);
      attr_             VARCHAR2(2000);
   
      CURSOR get_level1_part IS
         SELECT contract, part_no, png
         FROM LEVEL_1_PART_TAB
         WHERE contract = contract_
         AND   part_no LIKE local_part_no_
         AND   png     LIKE local_png_;
   
      -- cursor to copy MS set
      CURSOR get_ms_set IS
         SELECT contract,
                part_no,
                png,
                ms_set,
                last_run_date,
                qty_onhand,
                qty_allocated
         FROM LEVEL_1_PART_BY_MS_SET_TAB
         WHERE contract = contract_
         AND   part_no LIKE local_part_no_
         AND   png     LIKE local_png_
         AND   ms_set = from_ms_set_;
   
      -- cursor to copy forecasts
      CURSOR get_forecast IS
         SELECT *
         FROM LEVEL_1_FORECAST_TAB
         WHERE contract = contract_
         AND   part_no  LIKE local_part_no_
         AND   png      LIKE local_png_
         AND   ms_set   = from_ms_set_;
   
      -- cursor to copy MS receipts
      CURSOR get_receipt IS
         SELECT *
         FROM MS_RECEIPT_TAB
         WHERE contract = contract_
         AND   part_no  LIKE local_part_no_
         AND   png      LIKE local_png_
         AND   ms_set   = from_ms_set_;
   
      -- cursor to copy MS action messages
      CURSOR get_message IS
         SELECT *
         FROM LEVEL_1_MESSAGE_TAB
         WHERE contract = contract_
         AND   part_no  LIKE local_part_no_
         AND   png      LIKE local_png_
         AND   ms_set   = from_ms_set_;
   
      -- cursor to copy demands and supplies
      CURSOR get_demands IS
         SELECT *
         FROM PEGGED_SUPPLY_DEMAND_TAB
         WHERE contract = contract_
         AND   part_no  LIKE local_part_no_
         AND   png      LIKE local_png_
         AND   ms_set   = from_ms_set_;
   
      -- Cursor to copy already created supply orders
      CURSOR get_supplies IS
         SELECT *
         FROM SUPPLY_ORDER_DETAIL_TAB
         WHERE contract = contract_
         AND   part_no  LIKE local_part_no_
         AND   png      LIKE local_png_
         AND   ms_set   = from_ms_set_;
      
      -- cursor to copy unconsumed forecast history
      CURSOR get_unconsumed_fcst_hist IS
         SELECT *
         FROM ROLLOUT_UNCONSUMED_FCST_TAB
         WHERE contract = contract_
         AND   part_no  LIKE local_part_no_
         AND   png      LIKE local_png_
         AND   ms_set   = from_ms_set_;
         
      CURSOR get_proj_receipt IS
         SELECT *
         FROM MS_RECEIPT_MTR_NETTING_TAB
         WHERE contract = contract_
         AND   part_no  LIKE local_part_no_
         AND   png      LIKE local_png_
         AND   ms_set   = from_ms_set_;
   
      CURSOR get_proj_invent_supply IS
         SELECT *
         FROM MASSCH_PROJ_PEG_INVENTORY_TAB
         WHERE contract = contract_
         AND   part_no  LIKE local_part_no_
         AND   png      LIKE local_png_
         AND   ms_set   = from_ms_set_;
         
   BEGIN
   
      -- Check whether user has access to site
      IF (contract_ IS NOT NULL) THEN
         User_Allowed_Site_API.Exist(Fnd_Session_API.Get_Fnd_User, contract_);
      ELSE
         Error_Sys.Appl_General(lu_name_, 'SITEISNULL: Site must have a value');
      END IF;
   
      -- Validate target MS set
      IF to_ms_set_ IS NULL THEN
         Error_Sys.Appl_General(lu_name_, 'MSSETISNULL: MS Set must have a value');
      ELSIF to_ms_set_ = 1 THEN
         Error_Sys.Appl_General(lu_name_, 'CANNOTCOPY: Can not overwrite Master schedule set 1');
      ELSE
         Master_Sched_Set_API.Exist(to_ms_set_);
      END IF;
   
      -- Check if level 0 or level 1 processes are running first.
      IF (Level_1_Part_Util_API.Is_Level_One_Running (
             contract_     => contract_,
             part_no_      => NULL,
             png_          => NULL,
             ms_set_       => from_ms_set_ ) = 1) THEN
         Error_Sys.Appl_General(lu_name_, 'LEV1ORIGINISRUNNING: Level 1 is currently running on the origin MS Set :P1 Site :P2.', from_ms_set_, contract_);
      END IF;
   
      IF (Level_1_Part_Util_API.Is_Level_One_Running (
             contract_     => contract_,
             part_no_      => NULL,
             png_          => NULL,
             ms_set_       => to_ms_set_ ) = 1) THEN
         Error_Sys.Appl_General(lu_name_, 'LEV1DESTISRUNNING: Level 1 is currently running on the destination MS Set :P1 Site :P2.', to_ms_set_, contract_);
      END IF;
   
      -- If everything ok starts clone
      FOR rec_ IN get_level1_part LOOP         
         -- Remove existing data for fresh data copy
         DELETE FROM LEVEL_1_PART_BY_MS_SET_TAB  WHERE contract = rec_.contract AND part_no = rec_.part_no AND png = rec_.png AND ms_set = to_ms_set_;
         DELETE FROM LEVEL_1_FORECAST_TAB        WHERE contract = rec_.contract AND part_no = rec_.part_no AND png = rec_.png AND ms_set = to_ms_set_;
         DELETE FROM MS_RECEIPT_TAB              WHERE contract = rec_.contract AND part_no = rec_.part_no AND png = rec_.png AND ms_set = to_ms_set_;
         DELETE FROM LEVEL_1_MESSAGE_TAB         WHERE contract = rec_.contract AND part_no = rec_.part_no AND png = rec_.png AND ms_set = to_ms_set_;
         DELETE FROM PEGGED_SUPPLY_DEMAND_TAB    WHERE contract = rec_.contract AND part_no = rec_.part_no AND png = rec_.png AND ms_set = to_ms_set_;
         DELETE FROM SUPPLY_ORDER_DETAIL_TAB     WHERE contract = rec_.contract AND part_no = rec_.part_no AND png = rec_.png AND ms_set = to_ms_set_;
         DELETE FROM ROLLOUT_UNCONSUMED_FCST_TAB WHERE contract = rec_.contract AND part_no = rec_.part_no AND png = rec_.png AND ms_set = to_ms_set_;
         DELETE FROM MS_RECEIPT_MTR_NETTING_TAB WHERE contract = rec_.contract AND part_no = rec_.part_no AND png = rec_.png AND ms_set = to_ms_set_;
         DELETE FROM MASSCH_PROJ_PEG_INVENTORY_TAB WHERE contract = rec_.contract AND part_no = rec_.part_no AND png = rec_.png AND ms_set = to_ms_set_;
      END LOOP;
   
      -- Copy MS set
      FOR rec_ IN get_ms_set LOOP 
         Client_SYS.Clear_Attr(attr_);
         Client_SYS.Add_To_Attr ('CONTRACT', rec_.contract, attr_);
         Client_SYS.Add_To_Attr ('PART_NO', rec_.part_no, attr_);
         Client_SYS.Add_To_Attr ('PNG', rec_.png, attr_);
         Client_SYS.Add_To_Attr ('MS_SET', to_ms_set_, attr_);
         Client_SYS.Add_To_Attr ('QTY_ONHAND', rec_.qty_onhand, attr_);
         Client_SYS.Add_To_Attr ('QTY_ALLOCATED', rec_.qty_allocated, attr_);
         Client_SYS.Add_To_Attr ('LAST_RUN_DATE', rec_.last_run_date, attr_);
         Level_1_Part_By_Ms_Set_API.New__(info_, objid_, objversion_, attr_, 'DO');
      END LOOP;
   
      -- Copy Forecasts
      FOR rec_ IN get_forecast LOOP
         -- Bypass all validations
         rec_.ms_set := to_ms_set_;
         rec_.rowkey := NULL;
         INSERT
            INTO level_1_forecast_tab
            VALUES rec_;
                  
      END LOOP;
   
      -- Copy MS Receipts
      FOR rec_ IN get_receipt LOOP
         Client_SYS.Clear_Attr(attr_);
         Client_SYS.Add_To_Attr ('CONTRACT', rec_.contract, attr_);
         Client_SYS.Add_To_Attr ('PART_NO', rec_.part_no, attr_);
         Client_SYS.Add_To_Attr ('PNG', rec_.png, attr_);
         Client_SYS.Add_To_Attr ('MS_SET', to_ms_set_, attr_);
         Client_SYS.Add_To_Attr ('MS_DATE', rec_.ms_date, attr_);
         Client_SYS.Add_To_Attr ('LINE_NO', rec_.line_no, attr_);
         Client_SYS.Add_To_Attr ('MASTER_SCHED_RCPT', rec_.master_sched_rcpt, attr_);
         Client_SYS.Add_To_Attr ('START_DATE', rec_.start_date, attr_);
         Client_SYS.Add_To_Attr ('ACTIVITY_SEQ', rec_.activity_seq, attr_);
         Client_SYS.Add_To_Attr ('SYSGEN_FLAG_DB', rec_.sysgen_flag, attr_);
         MS_Receipt_API.New__ (info_, objid_, objversion_, attr_,'DO');
      END LOOP;
   
      -- Copy MS action messages
      FOR rec_ IN get_message LOOP
         Client_SYS.Clear_Attr(attr_);
         Client_SYS.Add_To_Attr ('CONTRACT', rec_.contract, attr_);
         Client_SYS.Add_To_Attr ('PART_NO', rec_.part_no, attr_);
         Client_SYS.Add_To_Attr ('PNG', rec_.png, attr_);
         Client_SYS.Add_To_Attr ('MS_SET', to_ms_set_, attr_);
         Client_SYS.Add_To_Attr ('PART_ACTION_SEQ', rec_.part_action_seq, attr_);
         Client_SYS.Add_To_Attr ('MS_DATE', rec_.ms_date, attr_);
         Client_SYS.Add_To_Attr ('ORDER_NO', rec_.order_no, attr_);
         Client_SYS.Add_To_Attr ('LINE_NO', rec_.line_no, attr_);
         Client_SYS.Add_To_Attr ('RELEASE_NO', rec_.release_no, attr_);
         Client_SYS.Add_To_Attr ('LINE_ITEM_NO', rec_.line_item_no, attr_);
         Client_SYS.Add_To_Attr ('ORDER_TYPE_DB', rec_.order_type, attr_);
         Client_SYS.Add_To_Attr ('MSG_CODE', rec_.msg_code, attr_);
         Client_SYS.Add_To_Attr ('ACTIVITY_SEQ', rec_.activity_seq, attr_);
         Level_1_Message_API.New__ (info_, objid_, objversion_, attr_,'DO');
      END LOOP;
   
      -- Copy pegged supply demands
      FOR rec_ IN get_demands LOOP
         Client_SYS.Clear_Attr(attr_);
         Client_SYS.Add_To_Attr ('MS_SUPPLY_DEMAND_STATUS', rec_.ms_supply_demand_status, attr_);
         Pegged_Supply_Demand_API.Batch_New__ ( rec_.contract,
                                                rec_.part_no,
                                                rec_.png,
                                                to_ms_set_,
                                                rec_.order_no,
                                                rec_.line_no,
                                                rec_.release_no,
                                                rec_.line_item_no,
                                                rec_.order_type,
                                                rec_.qty_supply,
                                                rec_.qty_demand,
                                                rec_.date_required,
                                                rec_.status_code,
                                                rec_.activity_seq,
                                                rec_.qty_applied,
                                                rec_.available,
                                                info_);
      END LOOP;
   
      -- Copy supplies generated
      FOR rec_ IN get_supplies LOOP
         Supply_Order_Detail_API.Batch_New__( rec_.contract,
                                              rec_.part_no,
                                              rec_.png,
                                              to_ms_set_,
                                              rec_.ms_date,
                                              rec_.line_no,
                                              rec_.activity_seq,
                                              rec_.supply_order_type,
                                              NULL,
                                              rec_.supply_order_no,
                                              rec_.supply_release_no,
                                              rec_.supply_sequence_no,
                                              rec_.order_qty,
                                              rec_.order_created);
      END LOOP;
      
      -- Copy unconsumed forecast history
      FOR rec_ IN get_unconsumed_fcst_hist LOOP
         Rollout_Unconsumed_Fcst_API.New( rec_.contract,
                                          rec_.part_no,
                                          rec_.png,
                                          to_ms_set_,
                                          rec_.orig_ms_date,
                                          rec_.rollout_date,
                                          rec_.unconsumed_forecast);
      END LOOP;
   
      FOR rec_ IN get_proj_invent_supply LOOP
         Massch_Proj_Peg_Inventory_API.Batch_New__(rec_.contract,
                                                   rec_.part_no,
                                                   rec_.png,
                                                   to_ms_set_,
                                                   rec_.activity_seq,
                                                   rec_.configuration_id,
                                                   rec_.location_no,
                                                   rec_.lot_batch_no,
                                                   rec_.serial_no,
                                                   rec_.eng_chg_level,
                                                   rec_.waiv_dev_rej_no,
                                                   rec_.qty_supply,
                                                   rec_.qty_applied,
                                                   rec_.qty_reserved,
                                                   rec_.available);                                                                                                                                                                                                                                         
      END LOOP;
   
      FOR rec_ IN get_proj_receipt LOOP
         Ms_Receipt_Mtr_Netting_API.Batch_New__(rec_.contract,
                                              rec_.part_no,
                                              rec_.png,
                                              to_ms_set_,
                                              rec_.ms_date,   
                                              rec_.activity_seq,
                                              rec_.line_no,
                                              rec_.mtr_qty,
                                              rec_.mtr_transfer_type,
                                              rec_.from_activity_seq,
                                              rec_.requisition_no,
                                              rec_.is_forecast);
                                              
      END LOOP;
   
   END Core;

BEGIN
   General_SYS.Init_Method(LEVEL_1_FORECAST_UTIL_API.lu_name_, 'LEVEL_1_FORECAST_UTIL_API', 'Copy_Entire_Master_Schedule');
   Core(contract_, from_ms_set_, to_ms_set_, part_no_, png_);
END Copy_Entire_Master_Schedule;


PROCEDURE Add_Forecast (
   contract_      IN VARCHAR2,
   part_no_       IN VARCHAR2,
   png_           IN VARCHAR2,
   from_ms_set_   IN NUMBER,
   to_ms_set_     IN NUMBER,
   start_date_    IN DATE,
   copy_lev0_     IN NUMBER,
   copy_lev1_     IN NUMBER )
IS
   
   PROCEDURE Core (
      contract_      IN VARCHAR2,
      part_no_       IN VARCHAR2,
      png_           IN VARCHAR2,
      from_ms_set_   IN NUMBER,
      to_ms_set_     IN NUMBER,
      start_date_    IN DATE,
      copy_lev0_     IN NUMBER,
      copy_lev1_     IN NUMBER )
   IS
      local_contract_   LEVEL_1_FORECAST.contract%TYPE;
      local_part_no_    LEVEL_1_FORECAST.part_no%TYPE;
      local_png_        LEVEL_1_FORECAST_TAB.png%TYPE;
      ms_date_          LEVEL_1_FORECAST.ms_date%TYPE;
      forecast_lev0_    LEVEL_1_FORECAST.forecast_lev0%TYPE;
      forecast_lev1_    LEVEL_1_FORECAST.forecast_lev1%TYPE;
      objid_            LEVEL_1_FORECAST.objid%TYPE;
      objversion_       VARCHAR2(2000);
      info_             VARCHAR2(2000);
      attr_             VARCHAR2(2000);
      sysgen_yes_client_   VARCHAR2(200) := Sysgen_API.Get_Client_Value(0);
      prop_ms_rcpt_client_ VARCHAR2(200) := Master_Sched_Status_API.Get_Client_Value(0);
   
      CURSOR get_forecast IS
         SELECT contract, part_no, png, ms_date, activity_seq,
                NVL(forecast_lev0, 0) forecast_lev0, NVL(forecast_lev1, 0) forecast_lev1
         FROM LEVEL_1_FORECAST_TAB
         WHERE contract LIKE contract_
         AND   part_no  LIKE part_no_
         AND   png      LIKE png_
         AND   ms_set     = from_ms_set_
         AND   ms_date   >= TRUNC(start_date_)
         AND   ms_date   >  TRUNC(Level_1_Part_API.Get_Demand_Tf_Date (
                                                    contract,
                                                    part_no,
                                                    png,
                                                    ms_set))
         AND  (NVL(forecast_lev0, 0) > 0 OR
               NVL(forecast_lev1, 0) > 0)
         ORDER BY contract,
                  part_no,
                  png,
                  ms_date;
   
      CURSOR get_obj(activity_seq_ NUMBER) IS
         SELECT objid,
                objversion
         FROM LEVEL_1_FORECAST
         WHERE contract = local_contract_
         AND   part_no  = local_part_no_
         AND   png      = local_png_
         AND   ms_set   = to_ms_set_
         AND   ms_date  = ms_date_
         AND   activity_seq = activity_seq_;
   
   BEGIN
   
      -- check whether user has access to site
      IF (contract_ IS NOT NULL AND contract_ != '%') THEN
         User_Allowed_Site_API.Exist(Fnd_Session_API.Get_Fnd_User, contract_);
      END IF;
   
      -- Validate MS set
      IF to_ms_set_ IS NULL THEN
         Error_Sys.Appl_General(lu_name_, 'MSSETISNULL2: MS Set must have a value');   
      ELSE
         Master_Sched_Set_API.Exist(to_ms_set_);
      END IF;
   
      -- Check if level 0 or level 1 processes are running first.
      IF (Level_1_Part_Util_API.Is_Level_One_Running (
             contract_     => contract_,
             part_no_      => NULL,
             png_          => NULL,
             ms_set_       => from_ms_set_ ) = 1) THEN
         Error_Sys.Appl_General(lu_name_, 'LEV1ORIGINISRUNNING: Level 1 is currently running on the origin MS Set :P1 Site :P2.', from_ms_set_, contract_);
      END IF;
   
      IF (Level_1_Part_Util_API.Is_Level_One_Running (
             contract_     => contract_,
             part_no_      => NULL,
             png_          => NULL,
             ms_set_       => to_ms_set_ ) = 1) THEN
         Error_Sys.Appl_General(lu_name_, 'LEV1DESTISRUNNING: Level 1 is currently running on the destination MS Set :P1 Site :P2.', to_ms_set_, contract_);
      END IF;
   
      FOR rec IN get_forecast LOOP
   
         local_contract_ :=  rec.contract;
         local_part_no_  :=  rec.part_no;
         local_png_      :=  rec.png;
         ms_date_        :=  rec.ms_date;
   
         Client_SYS.Clear_Attr(attr_);
   
         IF (NOT Level_1_Part_By_Ms_Set_API.Check_Exist (
                    rec.contract,
                    rec.part_no,
                    rec.png,   
                    to_ms_set_)) THEN
   
            Level_1_Part_By_Ms_Set_API.Batch_New__ (
               rec.contract,
               rec.part_no,
               rec.png,  
               to_ms_set_,
               TRUNC(Site_API.Get_Site_Date(rec.contract)));
   
         END IF;
   
         IF (Level_1_Forecast_API.Check_Exist (
                rec.contract,
                rec.part_no,
                rec.png,
                to_ms_set_,
                rec.activity_seq,
                rec.ms_date ) = TRUE) THEN
   
            IF (copy_lev0_ = 1) THEN
                forecast_lev0_ := Level_1_Forecast_Api.Get_Forecast_Lev0 (
                                     rec.contract,
                                     rec.part_no,
                                     rec.png,
                                     to_ms_set_,
                                     rec.activity_seq,
                                     rec.ms_date);
               forecast_lev0_  := nvl(forecast_lev0_, 0);
               Client_SYS.Add_To_Attr( 'FORECAST_LEV0', forecast_lev0_ + rec.forecast_lev0, attr_);
            END IF;
   
            IF (copy_lev1_ = 1) THEN
                forecast_lev1_ := Level_1_Forecast_Api.Get_Forecast_Lev1 (
                                     rec.contract,
                                     rec.part_no,
                                     rec.png,
                                     to_ms_set_,
                                     rec.activity_seq,
                                     rec.ms_date);
               forecast_lev1_  := nvl(forecast_lev1_, 0);
               Client_SYS.Add_To_Attr( 'FORECAST_LEV1', forecast_lev1_ + rec.forecast_lev1, attr_);
            END IF;
   
            OPEN  get_obj(rec.activity_seq);
            FETCH get_obj INTO objid_, objversion_;
            CLOSE get_obj;
   
            Level_1_Forecast_API.Modify__(info_, objid_, objversion_, attr_,'DO');
   
         ELSE
   
            Client_SYS.Add_To_Attr( 'CONTRACT', local_contract_, attr_ );
            Client_SYS.Add_To_Attr( 'PART_NO', local_part_no_, attr_ );
            Client_SYS.Add_To_Attr( 'ACTIVITY_SEQ', rec.activity_seq, attr_ );
            Client_SYS.Add_To_Attr( 'PNG', local_png_, attr_ );
            Client_SYS.Add_To_Attr( 'MS_SET', to_ms_set_, attr_);
            Client_SYS.Add_To_Attr( 'MS_DATE', rec.ms_date, attr_ );
            Client_SYS.Add_To_Attr( 'MASTER_SCHED_RCPT', 0, attr_ );
            Client_SYS.Add_To_Attr( 'SYSGEN_FLAG', sysgen_yes_client_, attr_ );
            Client_SYS.Add_To_Attr( 'MASTER_SCHED_STATUS', prop_ms_rcpt_client_, attr_ );
   
            IF (copy_lev0_ = 1) THEN
               Client_SYS.Add_To_Attr( 'FORECAST_LEV0', rec.forecast_lev0, attr_);
            END IF;
   
            IF (copy_lev1_ = 1) THEN
               Client_SYS.Add_To_Attr( 'FORECAST_LEV1', rec.forecast_lev1, attr_);
            END IF;
   
            IF ( (copy_lev0_ = 1 AND nvl(rec.forecast_lev0, 0) > 0) OR (copy_lev1_ = 1 AND nvl(rec.forecast_lev1, 0) > 0) ) THEN
               Level_1_Forecast_API.New__(info_, objid_, objversion_, attr_, 'DO');
            END IF;
         END IF;
      END LOOP;
   
   EXCEPTION
      WHEN OTHERS THEN
         IF Error_SYS.Is_Foundation_Error(SQLCODE) THEN
            RAISE;
         END IF;
   
         Error_Sys.Appl_General (lu_name_, 'ADDFCST1: Error :P1 occurred while running LEVEL_1_FORECAST_UTIL_API.Add_Forecast for Site :P2 Part No :P3.', SQLERRM, contract_, part_no_);
   END Core;

BEGIN
   General_SYS.Init_Method(LEVEL_1_FORECAST_UTIL_API.lu_name_, 'LEVEL_1_FORECAST_UTIL_API', 'Add_Forecast');
   Core(contract_, part_no_, png_, from_ms_set_, to_ms_set_, start_date_, copy_lev0_, copy_lev1_);
END Add_Forecast;


PROCEDURE Reset_Forecast (
   contract_     IN VARCHAR2,
   part_no_      IN VARCHAR2,
   png_          IN VARCHAR2,
   to_ms_set_    IN NUMBER,
   start_date_   IN DATE,
   copy_lev0_    IN NUMBER,
   copy_lev1_    IN NUMBER )
IS
   
   PROCEDURE Core (
      contract_     IN VARCHAR2,
      part_no_      IN VARCHAR2,
      png_          IN VARCHAR2,
      to_ms_set_    IN NUMBER,
      start_date_   IN DATE,
      copy_lev0_    IN NUMBER,
      copy_lev1_    IN NUMBER )
   IS
      objid_            LEVEL_1_FORECAST.objid%TYPE;
      objversion_       VARCHAR2(2000);
      info_             VARCHAR2(2000);
      attr_             VARCHAR2(2000);
      remove_forecast_  BOOLEAN;
   
      CURSOR reset IS
      SELECT objid,
             objversion,
             contract,
             part_no,
             png,
             ms_set,
             activity_seq,
             ms_date,
             NVL(forecast_lev0, 0) forecast_lev0,
             NVL(forecast_lev1, 0) forecast_lev1,
             NVL(firm_orders, 0) firm_orders,
             NVL(rel_ord_rcpt, 0) rel_ord_rcpt,
             NVL(sched_orders, 0) sched_orders,
             NVL(supply, 0) supply,
             NVL(consumed_forecast, 0) consumed_forecast,
             NVL(avail_to_prom, 0) avail_to_prom,
             NVL(consumed_supply, 0) consumed_supply,
             NVL(actual_demand, 0) actual_demand,
             NVL(planned_demand, 0) planned_demand
      FROM   LEVEL_1_FORECAST
      WHERE  contract LIKE contract_
      AND    part_no  LIKE part_no_
      AND    png      LIKE png_
      AND    NVL(consumed_forecast,0) = 0
      AND    ms_set          = to_ms_set_
      AND    ms_date >= TRUNC(start_date_)
      AND    ms_date >  TRUNC(Level_1_Part_API.Get_Demand_Tf_Date (contract,
                                                                    part_no,
                                                                    png,
                                                                    ms_set));
   
   BEGIN
   
      -- check whether user has access to site
      IF (contract_ IS NOT NULL AND contract_ != '%') THEN
         User_Allowed_Site_API.Exist(Fnd_Session_API.Get_Fnd_User, contract_);
      END IF;
   
      -- Check if level 0 or level 1 processes are running first.
      IF (Level_1_Part_Util_API.Is_Level_One_Running (
             contract_     => contract_,
             part_no_      => NULL,
             png_          => NULL,
             ms_set_       => to_ms_set_ ) = 1) THEN
         Error_Sys.Appl_General(lu_name_, 'LEV1DESTISRUNNING: Level 1 is currently running on the destination MS Set :P1 Site :P2.', to_ms_set_, contract_);
      END IF;
   
      FOR rec IN reset LOOP
         IF (rec.firm_orders <> 0 OR rec.rel_ord_rcpt <> 0 OR rec.sched_orders <> 0 OR rec.supply <> 0 OR rec.consumed_forecast <> 0 OR 
             rec.avail_to_prom <> 0 OR rec.consumed_supply <> 0 OR rec.actual_demand <> 0 OR rec.planned_demand <> 0) THEN
            remove_forecast_ := FALSE;
         ELSIF (copy_lev0_ = 1 AND copy_lev1_ = 1) THEN
            remove_forecast_ := TRUE;
         ELSIF(copy_lev0_ = 1 AND rec.forecast_lev1 = 0) THEN
            remove_forecast_ := TRUE;
         ELSIF (copy_lev1_ = 1 AND rec.forecast_lev0 = 0) THEN
            remove_forecast_ := TRUE;
         ELSIF (copy_lev0_ = 0 AND copy_lev1_ = 0 AND rec.forecast_lev0 = 0 AND rec.forecast_lev1 = 0) THEN
            remove_forecast_ := TRUE;
         ELSE
            remove_forecast_ := FALSE;
         END IF;
         
         IF (remove_forecast_) THEN
            Level_1_Forecast_API.Remove(rec.contract, rec.part_no, rec.png, rec.ms_set, rec.activity_seq, rec.ms_date);
         ELSE
            Client_SYS.Clear_Attr(attr_);
   
            objid_      := rec.objid;
            objversion_ := rec.objversion;
   
            IF (copy_lev0_ = 1) THEN
               Client_SYS.Add_To_Attr( 'FORECAST_LEV0', 0, attr_);
            END IF;
   
            IF (copy_lev1_ = 1) THEN
               Client_SYS.Add_To_Attr( 'FORECAST_LEV1', 0, attr_);
            END IF;
   
            Level_1_Forecast_API.Modify__(info_, objid_, objversion_, attr_,'DO');
         END IF;
   
      END LOOP;
   
   EXCEPTION
      WHEN OTHERS THEN
         IF Error_SYS.Is_Foundation_Error(SQLCODE) THEN
            RAISE;
         END IF;
   
         Error_Sys.Appl_General (lu_name_, 'RESETFCST1: Error :P1 occurred while running LEVEL_1_FORECAST_UTIL_API.Reset_Forecast for Site :P2 Part No :P3.', SQLERRM, contract_, part_no_);
   END Core;

BEGIN
   General_SYS.Init_Method(LEVEL_1_FORECAST_UTIL_API.lu_name_, 'LEVEL_1_FORECAST_UTIL_API', 'Reset_Forecast');
   Core(contract_, part_no_, png_, to_ms_set_, start_date_, copy_lev0_, copy_lev1_);
END Reset_Forecast;


PROCEDURE Remove_Master_Schedule (
   contract_   IN VARCHAR2,   
   ms_set_     IN NUMBER)
IS
   
   PROCEDURE Core (
      contract_   IN VARCHAR2,   
      ms_set_     IN NUMBER)
   IS
   BEGIN
   
      -- Check whether user has access to site
      IF (contract_ IS NOT NULL) THEN
         User_Allowed_Site_API.Exist(Fnd_Session_API.Get_Fnd_User, contract_);      
      ELSE
         Error_Sys.Appl_General(lu_name_, 'SITEISNULL2: Site must have a value');
      END IF;
   
      -- Validate target MS set
      IF ms_set_ IS NULL THEN
         Error_Sys.Appl_General(lu_name_, 'MSSETISNULL2: MS Set must have a value');
      ELSIF ms_set_ = 1 THEN
         Error_Sys.Appl_General(lu_name_, 'CANNOTCOPY2: Can not remove Master schedule set 1');
      ELSE
         Master_Sched_Set_API.Exist(ms_set_);
      END IF;
   
      -- Check if level 0 or level 1 processes are running first.
      IF (Level_1_Part_Util_API.Is_Level_One_Running (
             contract_     => contract_,
             part_no_      => NULL,
             png_          => NULL,
             ms_set_       => ms_set_ ) = 1) THEN
         Error_Sys.Appl_General(lu_name_, 'LEV1ORIGINISRUNNING2: Level 1 is currently running on the origin MS Set :P1 Site :P2.', ms_set_, contract_);
      END IF;
         
      DELETE FROM LEVEL_1_PART_BY_MS_SET_TAB  WHERE contract = contract_ AND ms_set = ms_set_;
      DELETE FROM LEVEL_1_FORECAST_TAB        WHERE contract = contract_ AND ms_set = ms_set_;
      DELETE FROM MS_RECEIPT_TAB              WHERE contract = contract_ AND ms_set = ms_set_;
      DELETE FROM LEVEL_1_MESSAGE_TAB         WHERE contract = contract_ AND ms_set = ms_set_;
      DELETE FROM PEGGED_SUPPLY_DEMAND_TAB    WHERE contract = contract_ AND ms_set = ms_set_;
      DELETE FROM SUPPLY_ORDER_DETAIL_TAB     WHERE contract = contract_ AND ms_set = ms_set_;
      DELETE FROM LEVEL_1_PART_BY_MS_SET_TAB  WHERE contract = contract_ AND ms_set = ms_set_;
      DELETE FROM ROLLOUT_UNCONSUMED_FCST_TAB WHERE contract = contract_ AND ms_set = ms_set_;
   END Core;

BEGIN
   General_SYS.Init_Method(LEVEL_1_FORECAST_UTIL_API.lu_name_, 'LEVEL_1_FORECAST_UTIL_API', 'Remove_Master_Schedule');
   Core(contract_, ms_set_);
END Remove_Master_Schedule;


--@IgnoreMissingSysinit
FUNCTION Get_Sum_Fcst_Lev0 (
   contract_        IN VARCHAR2,
   part_no_         IN VARCHAR2,
   png_             IN VARCHAR2,
   ms_set_          IN NUMBER,
   begin_date_      IN DATE,
   end_date_        IN DATE ) RETURN NUMBER
IS
   
   FUNCTION Core (
      contract_        IN VARCHAR2,
      part_no_         IN VARCHAR2,
      png_             IN VARCHAR2,
      ms_set_          IN NUMBER,
      begin_date_      IN DATE,
      end_date_        IN DATE ) RETURN NUMBER
   IS
      sum_   NUMBER;
   BEGIN
      SELECT SUM(NVL(forecast_lev0, 0))
      INTO   sum_
      FROM   LEVEL_1_FORECAST_TAB
      WHERE  contract = contract_
      AND    part_no  = part_no_
      AND    png      = png_
      AND    ms_set   = ms_set_
      AND    ms_date BETWEEN begin_date_ AND end_date_;
      RETURN sum_;
   END Core;

BEGIN
   RETURN Core(contract_, part_no_, png_, ms_set_, begin_date_, end_date_);
END Get_Sum_Fcst_Lev0;


--@IgnoreMissingSysinit
FUNCTION Get_Sum_Fcst_Lev1 (
   contract_        IN VARCHAR2,
   part_no_         IN VARCHAR2,
   png_             IN VARCHAR2,
   ms_set_          IN NUMBER,
   begin_date_      IN DATE,
   end_date_        IN DATE ) RETURN NUMBER
IS
   
   FUNCTION Core (
      contract_        IN VARCHAR2,
      part_no_         IN VARCHAR2,
      png_             IN VARCHAR2,
      ms_set_          IN NUMBER,
      begin_date_      IN DATE,
      end_date_        IN DATE ) RETURN NUMBER
   IS
      sum_   NUMBER;
   BEGIN
      SELECT SUM(NVL(forecast_lev1, 0))
      INTO   sum_
      FROM   LEVEL_1_FORECAST_TAB
      WHERE  contract = contract_
      AND    part_no  = part_no_
      AND    png      = png_
      AND    ms_set   = ms_set_
      AND    ms_date BETWEEN begin_date_ AND end_date_;
      RETURN sum_;
   END Core;

BEGIN
   RETURN Core(contract_, part_no_, png_, ms_set_, begin_date_, end_date_);
END Get_Sum_Fcst_Lev1;


--@IgnoreMissingSysinit
FUNCTION Get_Sum_Con_Fcst (
   contract_        IN VARCHAR2,
   part_no_         IN VARCHAR2,
   png_             IN VARCHAR2,
   ms_set_          IN NUMBER,
   begin_date_      IN DATE,
   end_date_        IN DATE ) RETURN NUMBER
IS
   
   FUNCTION Core (
      contract_        IN VARCHAR2,
      part_no_         IN VARCHAR2,
      png_             IN VARCHAR2,
      ms_set_          IN NUMBER,
      begin_date_      IN DATE,
      end_date_        IN DATE ) RETURN NUMBER
   IS
      sum_   NUMBER;
   BEGIN
      SELECT SUM(NVL(consumed_forecast, 0))
      INTO   sum_
      FROM   LEVEL_1_FORECAST_TAB
      WHERE  contract = contract_
      AND    part_no  = part_no_
      AND    png      = png_
      AND    ms_set   = ms_set_
      AND    ms_date BETWEEN begin_date_ AND end_date_;
      RETURN sum_;
   END Core;

BEGIN
   RETURN Core(contract_, part_no_, png_, ms_set_, begin_date_, end_date_);
END Get_Sum_Con_Fcst;


--@IgnoreMissingSysinit
FUNCTION Get_Sum_Uncon_Fcst (
   contract_        IN VARCHAR2,
   part_no_         IN VARCHAR2,
   png_             IN VARCHAR2,
   ms_set_          IN NUMBER,
   begin_date_      IN DATE,
   end_date_        IN DATE ) RETURN NUMBER
IS
   
   FUNCTION Core (
      contract_        IN VARCHAR2,
      part_no_         IN VARCHAR2,
      png_             IN VARCHAR2,
      ms_set_          IN NUMBER,
      begin_date_      IN DATE,
      end_date_        IN DATE ) RETURN NUMBER
   IS
      sum_   NUMBER;
   BEGIN
      SELECT SUM(NVL(unconsumed_forecast, 0))
      INTO   sum_
      FROM   LEVEL_1_FORECAST
      WHERE  contract = contract_
      AND    part_no  = part_no_
      AND    png      = png_
      AND    ms_set   = ms_set_
      AND    ms_date BETWEEN begin_date_ AND end_date_;
      RETURN sum_;
   END Core;

BEGIN
   RETURN Core(contract_, part_no_, png_, ms_set_, begin_date_, end_date_);
END Get_Sum_Uncon_Fcst;


--@IgnoreMissingSysinit
FUNCTION Get_Sum_Act_Dem (
   contract_        IN VARCHAR2,
   part_no_         IN VARCHAR2,
   png_             IN VARCHAR2,
   ms_set_          IN NUMBER,
   begin_date_      IN DATE,
   end_date_        IN DATE ) RETURN NUMBER
IS
   
   FUNCTION Core (
      contract_        IN VARCHAR2,
      part_no_         IN VARCHAR2,
      png_             IN VARCHAR2,
      ms_set_          IN NUMBER,
      begin_date_      IN DATE,
      end_date_        IN DATE ) RETURN NUMBER
   IS
      sum_   NUMBER;
   BEGIN
      SELECT SUM(NVL(actual_demand, 0))
      INTO   sum_
      FROM   LEVEL_1_FORECAST_TAB
      WHERE  contract = contract_
      AND    part_no  = part_no_
      AND    png      = png_
      AND    ms_set   = ms_set_
      AND    ms_date BETWEEN begin_date_ AND end_date_;
      RETURN sum_;
   END Core;

BEGIN
   RETURN Core(contract_, part_no_, png_, ms_set_, begin_date_, end_date_);
END Get_Sum_Act_Dem;


--@IgnoreMissingSysinit
FUNCTION Get_Sum_Plan_Dem (
   contract_        IN VARCHAR2,
   part_no_         IN VARCHAR2,
   png_             IN VARCHAR2,
   ms_set_          IN NUMBER,
   begin_date_      IN DATE,
   end_date_        IN DATE ) RETURN NUMBER
IS
   
   FUNCTION Core (
      contract_        IN VARCHAR2,
      part_no_         IN VARCHAR2,
      png_             IN VARCHAR2,
      ms_set_          IN NUMBER,
      begin_date_      IN DATE,
      end_date_        IN DATE ) RETURN NUMBER
   IS
      sum_   NUMBER;
   BEGIN
      SELECT SUM(NVL(planned_demand, 0))
      INTO   sum_
      FROM   LEVEL_1_FORECAST_TAB
      WHERE  contract = contract_
      AND    part_no  = part_no_
      AND    png      = png_
      AND    ms_set   = ms_set_
      AND    ms_date BETWEEN begin_date_ AND end_date_;
      RETURN sum_;
   END Core;

BEGIN
   RETURN Core(contract_, part_no_, png_, ms_set_, begin_date_, end_date_);
END Get_Sum_Plan_Dem;


--@IgnoreMissingSysinit
FUNCTION Get_Sum_Supply (
   contract_        IN VARCHAR2,
   part_no_         IN VARCHAR2,
   png_             IN VARCHAR2,
   ms_set_          IN NUMBER,
   begin_date_      IN DATE,
   end_date_        IN DATE ) RETURN NUMBER
IS
   
   FUNCTION Core (
      contract_        IN VARCHAR2,
      part_no_         IN VARCHAR2,
      png_             IN VARCHAR2,
      ms_set_          IN NUMBER,
      begin_date_      IN DATE,
      end_date_        IN DATE ) RETURN NUMBER
   IS
      sum_   NUMBER;
   BEGIN
      SELECT SUM(NVL(supply, 0))
      INTO   sum_
      FROM   LEVEL_1_FORECAST_TAB
      WHERE  contract = contract_
      AND    part_no  = part_no_
      AND    png      = png_
      AND    ms_set   = ms_set_
      AND    ms_date BETWEEN begin_date_ AND end_date_;
      RETURN sum_;
   END Core;

BEGIN
   RETURN Core(contract_, part_no_, png_, ms_set_, begin_date_, end_date_);
END Get_Sum_Supply;


--@IgnoreMissingSysinit
FUNCTION Get_Sum_Con_Sup (
   contract_        IN VARCHAR2,
   part_no_         IN VARCHAR2,
   png_             IN VARCHAR2,
   ms_set_          IN NUMBER,
   begin_date_      IN DATE,
   end_date_        IN DATE ) RETURN NUMBER
IS
   
   FUNCTION Core (
      contract_        IN VARCHAR2,
      part_no_         IN VARCHAR2,
      png_             IN VARCHAR2,
      ms_set_          IN NUMBER,
      begin_date_      IN DATE,
      end_date_        IN DATE ) RETURN NUMBER
   IS
      sum_   NUMBER;
   BEGIN
      SELECT SUM(NVL(consumed_supply, 0))
      INTO   sum_
      FROM   LEVEL_1_FORECAST_TAB
      WHERE  contract = contract_
      AND    part_no  = part_no_
      AND    png      = png_
      AND    ms_set   = ms_set_
      AND    ms_date BETWEEN begin_date_ AND end_date_;
      RETURN sum_;
   END Core;

BEGIN
   RETURN Core(contract_, part_no_, png_, ms_set_, begin_date_, end_date_);
END Get_Sum_Con_Sup;


--@IgnoreMissingSysinit
FUNCTION Get_Sum_Firm_Ord (
   contract_        IN VARCHAR2,
   part_no_         IN VARCHAR2,
   png_             IN VARCHAR2,
   ms_set_          IN NUMBER,
   begin_date_      IN DATE,
   end_date_        IN DATE ) RETURN NUMBER
IS
   
   FUNCTION Core (
      contract_        IN VARCHAR2,
      part_no_         IN VARCHAR2,
      png_             IN VARCHAR2,
      ms_set_          IN NUMBER,
      begin_date_      IN DATE,
      end_date_        IN DATE ) RETURN NUMBER
   IS
      sum_   NUMBER;
   BEGIN
      SELECT SUM(NVL(firm_orders, 0))
      INTO   sum_
      FROM   LEVEL_1_FORECAST_TAB
      WHERE  contract = contract_
      AND    part_no  = part_no_
      AND    png      = png_
      AND    ms_set   = ms_set_
      AND    ms_date BETWEEN begin_date_ AND end_date_;
      RETURN sum_;
   END Core;

BEGIN
   RETURN Core(contract_, part_no_, png_, ms_set_, begin_date_, end_date_);
END Get_Sum_Firm_Ord;


--@IgnoreMissingSysinit
FUNCTION Get_Sum_Rel_Ord (
   contract_        IN VARCHAR2,
   part_no_         IN VARCHAR2,
   png_             IN VARCHAR2,
   ms_set_          IN NUMBER,
   begin_date_      IN DATE,
   end_date_        IN DATE ) RETURN NUMBER
IS
   
   FUNCTION Core (
      contract_        IN VARCHAR2,
      part_no_         IN VARCHAR2,
      png_             IN VARCHAR2,
      ms_set_          IN NUMBER,
      begin_date_      IN DATE,
      end_date_        IN DATE ) RETURN NUMBER
   IS
      sum_   NUMBER;
   BEGIN
      SELECT SUM(NVL(rel_ord_rcpt, 0))
      INTO   sum_
      FROM   LEVEL_1_FORECAST_TAB
      WHERE  contract = contract_
      AND    part_no  = part_no_
      AND    png      = png_
      AND    ms_set   = ms_set_
      AND    ms_date BETWEEN begin_date_ AND end_date_;
      RETURN sum_;
   END Core;

BEGIN
   RETURN Core(contract_, part_no_, png_, ms_set_, begin_date_, end_date_);
END Get_Sum_Rel_Ord;


--@IgnoreMissingSysinit
FUNCTION Get_Sum_Sch_Ord (
   contract_        IN VARCHAR2,
   part_no_         IN VARCHAR2,
   png_             IN VARCHAR2,
   ms_set_          IN NUMBER,
   begin_date_      IN DATE,
   end_date_        IN DATE ) RETURN NUMBER
IS
   
   FUNCTION Core (
      contract_        IN VARCHAR2,
      part_no_         IN VARCHAR2,
      png_             IN VARCHAR2,
      ms_set_          IN NUMBER,
      begin_date_      IN DATE,
      end_date_        IN DATE ) RETURN NUMBER
   IS
      sum_   NUMBER;
   BEGIN
      SELECT SUM(NVL(sched_orders, 0))
      INTO   sum_
      FROM   LEVEL_1_FORECAST_TAB
      WHERE  contract = contract_
      AND    part_no  = part_no_
      AND    png      = png_
      AND    ms_set   = ms_set_
      AND    ms_date BETWEEN begin_date_ AND end_date_;
      RETURN sum_;
   END Core;

BEGIN
   RETURN Core(contract_, part_no_, png_, ms_set_, begin_date_, end_date_);
END Get_Sum_Sch_Ord;


--@IgnoreMissingSysinit
FUNCTION Get_Sum_Ms_Rcpt (
   contract_        IN VARCHAR2,
   part_no_         IN VARCHAR2,
   png_             IN VARCHAR2,
   ms_set_          IN NUMBER,
   begin_date_      IN DATE,
   end_date_        IN DATE ) RETURN NUMBER
IS
   
   FUNCTION Core (
      contract_        IN VARCHAR2,
      part_no_         IN VARCHAR2,
      png_             IN VARCHAR2,
      ms_set_          IN NUMBER,
      begin_date_      IN DATE,
      end_date_        IN DATE ) RETURN NUMBER
   IS
      sum_   NUMBER;
   BEGIN
      SELECT SUM(NVL(master_sched_rcpt, 0))
      INTO   sum_
      FROM   LEVEL_1_FORECAST_TAB
      WHERE  contract = contract_
      AND    part_no  = part_no_
      AND    png      = png_
      AND    ms_set   = ms_set_
      AND    ms_date BETWEEN begin_date_ AND end_date_;
      RETURN sum_;
   END Core;

BEGIN
   RETURN Core(contract_, part_no_, png_, ms_set_, begin_date_, end_date_);
END Get_Sum_Ms_Rcpt;


--@IgnoreMissingSysinit
FUNCTION Get_Sum_Atp (
   contract_        IN VARCHAR2,
   part_no_         IN VARCHAR2,
   png_             IN VARCHAR2,
   ms_set_          IN NUMBER,
   begin_date_      IN DATE,
   end_date_        IN DATE ) RETURN NUMBER
IS
   
   FUNCTION Core (
      contract_        IN VARCHAR2,
      part_no_         IN VARCHAR2,
      png_             IN VARCHAR2,
      ms_set_          IN NUMBER,
      begin_date_      IN DATE,
      end_date_        IN DATE ) RETURN NUMBER
   IS
      sum_   NUMBER;
   BEGIN
      SELECT SUM(NVL(avail_to_prom, 0))
      INTO   sum_
      FROM   LEVEL_1_FORECAST_TAB
      WHERE  contract = contract_
      AND    part_no  = part_no_
      AND    png      = png_
      AND    ms_set   = ms_set_
      AND    ms_date BETWEEN begin_date_ AND end_date_;
      RETURN sum_;
   END Core;

BEGIN
   RETURN Core(contract_, part_no_, png_, ms_set_, begin_date_, end_date_);
END Get_Sum_Atp;


--@IgnoreMissingSysinit
FUNCTION Get_Sum_Avail_To_Prom (
   contract_        IN VARCHAR2,
   part_no_         IN VARCHAR2,
   png_             IN VARCHAR2,
   ms_set_          IN NUMBER,
   begin_date_      IN DATE,
   end_date_        IN DATE ) RETURN NUMBER
IS
   
   FUNCTION Core (
      contract_        IN VARCHAR2,
      part_no_         IN VARCHAR2,
      png_             IN VARCHAR2,
      ms_set_          IN NUMBER,
      begin_date_      IN DATE,
      end_date_        IN DATE ) RETURN NUMBER
   IS
      sum_   NUMBER;
   BEGIN
      SELECT SUM(NVL(avail_to_prom, 0))
      INTO   sum_
      FROM   LEVEL_1_FORECAST_TAB
      WHERE  contract = contract_
      AND    part_no  = part_no_
      AND    png      = png_
      AND    ms_set   = ms_set_
      AND    ms_date BETWEEN begin_date_ AND end_date_;
      RETURN sum_;
   END Core;

BEGIN
   RETURN Core(contract_, part_no_, png_, ms_set_, begin_date_, end_date_);
END Get_Sum_Avail_To_Prom;


--@IgnoreMissingSysinit
FUNCTION Get_Sum_Mtr_Demand (
   contract_   IN VARCHAR2,
   part_no_    IN VARCHAR2,
   png_        IN VARCHAR2,
   ms_set_     IN NUMBER,
   begin_date_ IN DATE,
   end_date_   IN DATE ) RETURN NUMBER
IS
   
   FUNCTION Core (
      contract_   IN VARCHAR2,
      part_no_    IN VARCHAR2,
      png_        IN VARCHAR2,
      ms_set_     IN NUMBER,
      begin_date_ IN DATE,
      end_date_   IN DATE ) RETURN NUMBER
   IS
      sum_  NUMBER;
   BEGIN
      SELECT SUM(NVL(mtr_demand_qty, 0)) INTO sum_
      FROM   LEVEL_1_FORECAST_TAB
      WHERE  contract = contract_
      AND    part_no  = part_no_
      AND    png      = png_
      AND    ms_set   = ms_set_
      AND    ms_date BETWEEN begin_date_ AND end_date_;
      RETURN sum_;
   END Core;

BEGIN
   RETURN Core(contract_, part_no_, png_, ms_set_, begin_date_, end_date_);
END Get_Sum_Mtr_Demand;


--@IgnoreMissingSysinit
FUNCTION Get_Sum_Mtr_Supply (
   contract_   IN VARCHAR2,
   part_no_    IN VARCHAR2,
   png_        IN VARCHAR2,
   ms_set_     IN NUMBER,
   begin_date_ IN DATE,
   end_date_   IN DATE ) RETURN NUMBER
IS
   
   FUNCTION Core (
      contract_   IN VARCHAR2,
      part_no_    IN VARCHAR2,
      png_        IN VARCHAR2,
      ms_set_     IN NUMBER,
      begin_date_ IN DATE,
      end_date_   IN DATE ) RETURN NUMBER
   IS
      sum_  NUMBER;
   BEGIN
      SELECT SUM(NVL(mtr_supply_qty, 0)) INTO sum_
      FROM   LEVEL_1_FORECAST_TAB
      WHERE  contract = contract_
      AND    part_no  = part_no_
      AND    png      = png_
      AND    ms_set   = ms_set_
      AND    ms_date BETWEEN begin_date_ AND end_date_;
      RETURN sum_;
   END Core;

BEGIN
   RETURN Core(contract_, part_no_, png_, ms_set_, begin_date_, end_date_);
END Get_Sum_Mtr_Supply;


FUNCTION Is_Import_Running (
   contract_ IN VARCHAR2,
   part_no_ IN VARCHAR2,
   ms_set_ IN VARCHAR2 ) RETURN NUMBER
IS
   
   FUNCTION Core (
      contract_ IN VARCHAR2,
      part_no_ IN VARCHAR2,
      ms_set_ IN VARCHAR2 ) RETURN NUMBER
   IS
      cursor_handle_check_ NUMBER;
      dummy_         NUMBER;
      stmt_check_    VARCHAR2(1000);
      process_       VARCHAR2(2000);
      exist_contract_ VARCHAR2(5);
      exist_user_     VARCHAR2(30);
      exist_part_no_  VARCHAR2(25);
      exist_ms_set_   NUMBER;
   
      contract_in_ VARCHAR2(5);
      part_no_in_  VARCHAR2(25);
      return_value_  NUMBER := 0;
   
      CURSOR c_site (contact_in_ VARCHAR2) IS
         SELECT contract
         FROM site_public
         WHERE EXISTS (SELECT 1 FROM user_allowed_site_pub
                       WHERE contract = site)
         AND   contract LIKE ( contact_in_ );
   
   BEGIN
      cursor_handle_check_ := dbms_sql.open_cursor;
   
      contract_in_ := nvl(contract_,'%');
      part_no_in_  := nvl(part_no_,'%');
   
      stmt_check_ :=
         'SELECT process FROM IMPORT_PROCESS_TAB ' ||
         'WHERE Client_SYS.Get_Item_Value(''PN'',process) = ''MS''';
   
      --@ApproveDynamicStatement(2005-12-14,pemase)
      dbms_sql.parse(cursor_handle_check_,stmt_check_, dbms_sql.native);
      dbms_sql.define_column(cursor_handle_check_,1, process_,20000);
      dummy_ := dbms_sql.execute(cursor_handle_check_);
      LOOP
         EXIT WHEN dbms_sql.fetch_rows( cursor_handle_check_ ) = 0;
         dbms_sql.column_value( cursor_handle_check_,1 , process_);
         exist_contract_ := Client_SYS.Get_Item_Value('CONTRACT',process_);
         exist_user_ := Client_SYS.Get_Item_Value('USER_ID',process_);
         exist_part_no_ := Client_SYS.Get_Item_Value('PART_NO',process_);
         exist_ms_set_ := to_number(Client_SYS.Get_Item_Value('MS_SET',process_));
         FOR cur_site IN c_site(contract_in_) LOOP
            IF exist_contract_ = cur_site.contract THEN
               IF (exist_part_no_ = '%' OR part_no_in_ = '%' OR exist_part_no_ = part_no_in_) AND
                  ( ms_set_ IS NULL OR exist_ms_set_ IS NULL OR ms_set_ = exist_ms_set_ ) THEN
                  return_value_ := 1;
                  EXIT;
               END IF;
            END IF;
         END LOOP;
         IF return_value_ = 1 THEN
            EXIT;
         END IF;
      END LOOP;
      dbms_sql.close_cursor(cursor_handle_check_);
      RETURN return_value_;
   EXCEPTION
      WHEN OTHERS THEN
         IF dbms_sql.is_open(cursor_handle_check_) THEN
            dbms_sql.close_cursor(cursor_handle_check_);
         END IF;
      RETURN return_value_;
   END Core;

BEGIN
   General_SYS.Init_Method(LEVEL_1_FORECAST_UTIL_API.lu_name_, 'LEVEL_1_FORECAST_UTIL_API', 'Is_Import_Running');
   RETURN Core(contract_, part_no_, ms_set_);
END Is_Import_Running;


PROCEDURE Validate_Params (
   message_ IN VARCHAR2 )
IS
   
   PROCEDURE Core (
      message_ IN VARCHAR2 )
   IS
      count_                  NUMBER;
      name_arr_               Message_SYS.name_table;
      value_arr_              Message_SYS.line_table;
   
      contract_               VARCHAR2(5);
      part_no_                VARCHAR2(25);
      target_ms_set_          NUMBER;
      start_date_             DATE;
      end_date_               DATE;
      period_length_          NUMBER;
      ptf_copy_               NUMBER;
      distribution_           NUMBER;
      budget_forecast_        VARCHAR2(1);
      on_non_workday_         VARCHAR2(2);
      scenario_id_            NUMBER;
      dummy_                  NUMBER :=0;
      lev1_part_not_exist     EXCEPTION;
   
      CURSOR get_contract IS
      SELECT 1
      FROM  LEVEL_1_PART_TAB
      WHERE contract         LIKE contract_
      AND   part_no          LIKE part_no_
      AND   EXISTS (SELECT 1 FROM user_allowed_site_pub
         WHERE site = contract);
   
   BEGIN
   
      Message_SYS.Get_Attributes(message_, count_, name_arr_, value_arr_);
   
      FOR n_ IN 1..count_ LOOP
         IF (name_arr_(n_) = 'CONTRACT') THEN
            contract_ := nvl(value_arr_(n_), '%');
         ELSIF (name_arr_(n_) = 'PART_NO') THEN
            part_no_ := nvl(value_arr_(n_), '%');
         ELSIF (name_arr_(n_) = 'TARGET_MS_SET') THEN
            target_ms_set_ := Client_SYS.Attr_Value_To_Number(value_arr_(n_));
         ELSIF (name_arr_(n_) = 'START_DATE') THEN
            start_date_ := Client_SYS.Attr_Value_To_Date(value_arr_(n_));
         ELSIF (name_arr_(n_) = 'END_DATE') THEN
            end_date_ := Client_SYS.Attr_Value_To_Date(value_arr_(n_));
         ELSIF (name_arr_(n_) = 'PERIOD_LENGTH') THEN
            period_length_ := Client_SYS.Attr_Value_To_Number(value_arr_(n_));
         ELSIF (name_arr_(n_) = 'DISTRIBUTION') THEN
            distribution_ := Client_SYS.Attr_Value_To_Number(value_arr_(n_));
         ELSIF (name_arr_(n_) = 'BUDGET_FORECAST') THEN
            budget_forecast_ := value_arr_(n_);
         ELSIF (name_arr_(n_) = 'ON_NON_WORKDAY') THEN
            on_non_workday_ := value_arr_(n_);
         ELSIF (name_arr_(n_) = 'PTF_COPY') THEN
            ptf_copy_ := Client_SYS.Attr_Value_To_Number(value_arr_(n_));
         ELSIF (name_arr_(n_) = 'SCENARIO_ID') THEN
            scenario_id_ := Client_SYS.Attr_Value_To_Number(value_arr_(n_));
         ELSE
            Error_SYS.Record_General(lu_name_, 'INCORRECT_MESSAGE: Item :P1 can not be used in this method.');
         END IF;
      END LOOP;
   
      OPEN get_contract;
      FETCH get_contract INTO dummy_;
      IF get_contract%NOTFOUND THEN
         CLOSE get_contract;
         RAISE lev1_part_not_exist;
      END IF;
      CLOSE get_contract;
   EXCEPTION
      WHEN lev1_part_not_exist THEN
         Error_Sys.Appl_General(lu_name_, 'NOLEVEL1PARTFORIMPORT: No level 1 part selected for import Demand/Planning forecasts. Check the existence of the selected level 1 part.');
   END Core;

BEGIN
   General_SYS.Init_Method(LEVEL_1_FORECAST_UTIL_API.lu_name_, 'LEVEL_1_FORECAST_UTIL_API', 'Validate_Params');
   Core(message_);
END Validate_Params;

-----------------------------------------------------------------------------
-------------------- LU SPECIFIC PROTECTED METHODS --------------------------
-----------------------------------------------------------------------------

PROCEDURE Initiate_ (
   contract_                      IN VARCHAR2,
   part_no_                       IN VARCHAR2,
   png_                           IN VARCHAR2,
   ms_set_                        IN NUMBER,
   run_date_                      IN DATE,
   demand_tf_                     IN DATE,
   planning_tf_                   IN DATE,
   qty_onhand_                    IN NUMBER,
   roll_flag_db_                  IN VARCHAR2,
   shop_order_proposal_flag_db_   IN VARCHAR2,
   create_fixed_ms_receipt_db_    IN VARCHAR2,
   split_manuf_acquired_          IN VARCHAR2,
   is_part_internally_sourced_    IN VARCHAR2,
   order_proposal_release_db_     IN VARCHAR2,
   manuf_supply_type_             IN VARCHAR2,
   acquired_supply_type_          IN VARCHAR2,
   prev_run_date_                 IN DATE,
   pur_lu_req_exists_             IN BOOLEAN,
   so_lu_prop_exists_             IN BOOLEAN,
   calendar_id_                   IN VARCHAR2,
   min_date_                      IN DATE,
   max_date_                      IN DATE,
   start_crp_calc_                IN BOOLEAN )
IS
   
   PROCEDURE Core (
      contract_                      IN VARCHAR2,
      part_no_                       IN VARCHAR2,
      png_                           IN VARCHAR2,
      ms_set_                        IN NUMBER,
      run_date_                      IN DATE,
      demand_tf_                     IN DATE,
      planning_tf_                   IN DATE,
      qty_onhand_                    IN NUMBER,
      roll_flag_db_                  IN VARCHAR2,
      shop_order_proposal_flag_db_   IN VARCHAR2,
      create_fixed_ms_receipt_db_    IN VARCHAR2,
      split_manuf_acquired_          IN VARCHAR2,
      is_part_internally_sourced_    IN VARCHAR2,
      order_proposal_release_db_     IN VARCHAR2,
      manuf_supply_type_             IN VARCHAR2,
      acquired_supply_type_          IN VARCHAR2,
      prev_run_date_                 IN DATE,
      pur_lu_req_exists_             IN BOOLEAN,
      so_lu_prop_exists_             IN BOOLEAN,
      calendar_id_                   IN VARCHAR2,
      min_date_                      IN DATE,
      max_date_                      IN DATE,
      start_crp_calc_                IN BOOLEAN )
   IS
      local_contract_             VARCHAR2(200);
      inventory_part_rec_         Inventory_Part_API.Public_Rec;
      inventory_part_plan_rec_    Inventory_Part_Planning_API.Public_Rec;
      from_date_                  DATE;
      to_date_                    DATE;
      local_master_sched_rcpt_    LEVEL_1_FORECAST_TAB.master_sched_rcpt%TYPE := NULL;
   
      CURSOR ms_rcpt_to_zero IS
         SELECT ms_date
         FROM level_1_forecast_tab
         WHERE part_no                    = part_no_
         AND   contract                   = contract_
         AND   png                        = png_
         AND   ms_set                     = ms_set_
         AND   ms_date                    < run_date_
         AND   NVL(master_sched_rcpt, 0)  > 0;
   
      CURSOR ms_sub_rcpt_to_rem IS
         SELECT ms_date, line_no
         FROM ms_receipt_tab
         WHERE part_no  = part_no_
         AND   contract = contract_
         AND   png      = png_
         AND   ms_set   = ms_set_
         AND   ms_date  < run_date_;
   
      CURSOR within_pt IS
         SELECT ms_date
         FROM level_1_forecast_tab
         WHERE part_no                   = part_no_
         AND   contract                  = contract_
         AND   png                       = png_
         AND   ms_set                    = ms_set_
         AND   NVL(master_sched_rcpt, 0) > 0
         AND   ms_date                   <= planning_tf_
         AND   sysgen_flag               = sysgen_yes_;
   
      CURSOR after_pt IS
         SELECT ms_date
         FROM level_1_forecast_tab
         WHERE part_no                   = part_no_
         AND   contract                  = contract_
         AND   png                       = png_
         AND   ms_set                    = ms_set_
         AND   ms_date                   > planning_tf_
         AND   NVL(master_sched_rcpt, 0) > 0
         AND   sysgen_flag               = sysgen_yes_;
   
      CURSOR after_pt2 IS
         SELECT ms_date, line_no
         FROM ms_receipt_tab
         WHERE part_no                   = part_no_
         AND   contract                  = contract_
         AND   png                       = png_
         AND   ms_set                    = ms_set_
         AND   ms_date                   > planning_tf_
         AND   NVL(master_sched_rcpt, 0) > 0
         AND   sysgen_flag               = sysgen_yes_;
   
      CURSOR fcst_supply_consumption IS
         SELECT ms_date
         FROM level_1_forecast_tab
         WHERE part_no              = part_no_
         AND   contract             = contract_
         AND   png                  = png_
         AND   ms_set               = ms_set_
         AND  (NVL(firm_orders,       0) > 0
            OR  NVL(rel_ord_rcpt,      0) > 0
            OR  NVL(sched_orders,      0) > 0
            OR  NVL(supply,            0) > 0
            OR  NVL(consumed_forecast, 0) > 0
            OR  NVL(avail_to_prom    , 0) > 0
            OR  NVL(consumed_supply  , 0) > 0
            OR  NVL(actual_demand    , 0) > 0
            OR  NVL(planned_demand   , 0) > 0);
   
      CURSOR zero_recs IS
         SELECT rowid
         FROM level_1_forecast_tab
         WHERE part_no                   = part_no_
         AND   contract                  = contract_
         AND   png                       = png_
         AND   ms_set                    = ms_set_
         AND   activity_seq              = 0
         AND   NVL(forecast_lev0, 0)     = 0
         AND   NVL(forecast_lev1, 0)     = 0
         AND   NVL(master_sched_rcpt, 0) = 0;
   
   BEGIN
   
      -- get part information.
      inventory_part_rec_ := Inventory_Part_API.Get (contract_, part_no_);
      inventory_part_plan_rec_ := Inventory_Part_Planning_API.Get (contract_, part_no_);
   
      IF (ms_set_ = 1 AND shop_order_proposal_flag_db_ != 'M') THEN
         -- Always remove proposals if ms_set is equal to 1 !!
         -- MS is now consistent how we delete proposals from MRP
         IF shop_order_proposal_flag_db_ = 'Y' THEN
            from_date_ := min_date_;
            to_date_ := planning_tf_;
         ELSE
            from_date_ := min_date_;
            to_date_ := max_date_;
         END IF;
            
         Remove_Shop_Proposal__(contract_, part_no_, png_, from_date_, to_date_, NULL, 0);
         
         $IF Component_Prosch_SYS.INSTALLED $THEN
            Remove_Production_Schedules__(
                  contract_,
                  part_no_,
                  png_,
                  from_date_,
                  to_date_);
         $END
   
         IF pur_lu_req_exists_ THEN
            Remove_Pur_Req__(contract_, part_no_, png_, from_date_, to_date_, NULL, 0);
         END IF;
         -- Remove unreleased distribution orders.
         $IF Component_Disord_SYS.INSTALLED $THEN
            Remove_Do__ (
                  contract_,
                  part_no_,
                  png_,
                  from_date_,
                  to_date_);
         $END
   
         Remove_Supply_Schedules___(contract_, part_no_, png_, from_date_, to_date_);
         
         $IF Component_Crp_SYS.INSTALLED $THEN
            IF (start_crp_calc_) THEN
               Crp_Mach_Operation_Util_API.Unload_By_Part_And_Source(contract_, part_no_, 'MSO');
               Crp_Mach_Operation_Util_API.Unload_By_Part_And_Source(contract_, part_no_, 'MS');
               Crp_Mach_Operation_Util_API.Unload_By_Part_And_Source(contract_, part_no_, 'PSC');
            END IF;
         $END
      ELSIF (ms_set_ != 1) THEN
         local_master_sched_rcpt_ := 0;
      END IF;
      
      -- Sysgen MS Rcpts forced to zero within planning timefence'
      IF (create_fixed_ms_receipt_db_ = Fnd_Boolean_API.DB_FALSE) THEN
         FOR within_rec IN within_pt LOOP
            Level_1_Message_API.Batch_New__(
               contract_      => contract_,
               part_no_       => part_no_,
               png_           => png_,
               ms_set_        => ms_set_,
               ms_date_       => within_rec.ms_date,
               order_no_      => NULL,
               line_no_       => NULL,
               release_no_    => NULL,
               line_item_no_  => NULL,
               order_type_db_ => NULL,
               activity_seq_  => NULL,
               msg_code_      => 'E527');
         END LOOP;
      END IF;
   
      -- Past due MS Rcpts forced to zero.
      FOR ms_rcpt_to_zero_rec IN ms_rcpt_to_zero  LOOP
   
         Level_1_Forecast_API.Batch_Modify__ (
            contract_            => contract_,
            part_no_             => part_no_,
            png_                 => png_,
            ms_set_              => ms_set_,
            activity_seq_        => 0,
            ms_date_             => ms_rcpt_to_zero_rec.ms_date,
            parent_contract_     => NULL,
            parent_part_         => NULL,
            forecast_lev0_       => NULL,
            forecast_lev1_       => NULL,
            consumed_forecast_   => NULL,
            actual_demand_       => NULL,
            planned_demand_      => NULL,
            supply_              => NULL,
            consumed_supply_     => NULL,
            firm_orders_         => NULL,
            sched_orders_        => NULL,
            rel_ord_rcpt_        => NULL,
            master_sched_rcpt_   => 0,
            avail_to_prom_       => NULL,
            roll_up_rcpt_        => NULL,
            net_avail_           => NULL,
            proj_avail_          => NULL,
            mtr_demand_qty_      => NULL,
            mtr_supply_qty_      => NULL,
            offset_              => NULL,
            roll_flag_db_        => NULL,
            sysgen_flag_         => NULL,
            master_sched_status_ => NULL,
            method_              => 'UPDATE' );
      END LOOP;
      
      FOR cursor_rec IN ms_sub_rcpt_to_rem LOOP
         Ms_Receipt_API.Batch_Remove__(
            contract_,
            part_no_,
            png_,
            ms_set_,
            cursor_rec.ms_date,
            cursor_rec.line_no);
      END LOOP;
   
      -- Proposed master_sched_rcpt is set to zero. They are recalculated in
      -- Calculate_Ms_Receipt_.
      FOR after_rec IN after_pt LOOP
   
         Level_1_Forecast_API.Batch_Modify__ (
            contract_            => contract_,
            part_no_             => part_no_,
            png_                 => png_,
            ms_set_              => ms_set_,
            activity_seq_        => 0,
            ms_date_             => after_rec.ms_date,
            parent_contract_     => NULL,
            parent_part_         => NULL,
            forecast_lev0_       => NULL,
            forecast_lev1_       => NULL,
            consumed_forecast_   => NULL,
            actual_demand_       => NULL,
            planned_demand_      => NULL,
            supply_              => NULL,
            consumed_supply_     => NULL,
            firm_orders_         => NULL,
            sched_orders_        => NULL,
            rel_ord_rcpt_        => NULL,
            master_sched_rcpt_   => 0,
            avail_to_prom_       => NULL,
            roll_up_rcpt_        => NULL,
            net_avail_           => NULL,
            proj_avail_          => NULL,
            mtr_demand_qty_      => NULL,
            mtr_supply_qty_      => NULL,
            offset_              => NULL,
            roll_flag_db_        => NULL,
            sysgen_flag_         => NULL,
            master_sched_status_ => NULL,
            method_              => 'UPDATE' );
      END LOOP;
         
      FOR after_rec2 IN after_pt2 LOOP
         Ms_Receipt_API.Batch_Remove__(
               contract_,
               part_no_,
               png_,
               ms_set_,
               after_rec2.ms_date,
               after_rec2.line_no);
      END LOOP;
   
      -- Demand, supply, consumed forecast and consumed supply is set to zero for the entire horizon. They are recalculated in Calculate_Ms_Receipt_.
      FOR cursor_rec IN fcst_supply_consumption LOOP
   
         Level_1_Forecast_API.Batch_Modify__ (
            contract_            => contract_,
            part_no_             => part_no_,
            png_                 => png_,
            ms_set_              => ms_set_,
            activity_seq_        => 0,
            ms_date_             => cursor_rec.ms_date,
            parent_contract_     => NULL,
            parent_part_         => NULL,
            forecast_lev0_       => NULL,
            forecast_lev1_       => NULL,
            consumed_forecast_   => 0,
            actual_demand_       => 0,
            planned_demand_      => 0,
            supply_              => 0,
            consumed_supply_     => 0,
            firm_orders_         => 0,
            sched_orders_        => 0,
            rel_ord_rcpt_        => 0,
            master_sched_rcpt_   => local_master_sched_rcpt_,
            avail_to_prom_       => 0,
            roll_up_rcpt_        => 0,
            net_avail_           => NULL,
            proj_avail_          => NULL,
            mtr_demand_qty_      => NULL,
            mtr_supply_qty_      => NULL,
            offset_              => NULL,
            roll_flag_db_        => NULL,
            sysgen_flag_         => NULL,
            master_sched_status_ => NULL,
            method_              => 'UPDATE' );
   
      END LOOP;
   
      -- There is a risk of getting a lot of unnecessary zero records, if
      -- those fixed Master Schedule receipts which are inside planning 0
      FOR zero_rec IN zero_recs LOOP
         Level_1_Forecast_API.Batch_Remove__(zero_rec.rowid);
      END LOOP;
   
      IF NOT Level_1_Forecast_API.Check_Exist(contract_, part_no_, png_, ms_set_, 0, run_date_) THEN
         -- Create a new record for run date if not exists
         Level_1_Forecast_API.Batch_New__(
            contract_            => contract_,
            part_no_             => part_no_,
            png_                 => png_,
            ms_set_              => ms_set_,
            activity_seq_        => 0,
            ms_date_             => run_date_,
            parent_contract_     => NULL,
            parent_part_         => NULL,
            forecast_lev0_       => 0,
            forecast_lev1_       => 0,
            consumed_forecast_   => 0,
            actual_demand_       => 0,
            planned_demand_      => 0,
            supply_              => 0,
            consumed_supply_     => 0,
            firm_orders_         => 0,
            sched_orders_        => 0,
            rel_ord_rcpt_        => 0,
            master_sched_rcpt_   => 0,
            avail_to_prom_       => 0,
            roll_up_rcpt_        => NULL,
            net_avail_           => 0,
            proj_avail_          => 0,
            mtr_demand_qty_      => 0,
            mtr_supply_qty_      => 0,
            offset_              => NULL,
            sysgen_flag_         => Sysgen_API.Decode(sysgen_yes_),
            master_sched_status_ => Master_Sched_Status_API.Decode(Master_Sched_Status_API.DB_PROPOSED_MS_RECEIPT));
   
      END IF;
   
      IF NOT Level_1_Forecast_API.Check_Exist(contract_, part_no_, png_, ms_set_, 0, TRUNC(Work_Time_Calendar_API.Get_Next_Work_Day(calendar_id_, planning_tf_))) THEN
         -- Create a new record for the date outside PTF if not exists
         Level_1_Forecast_API.Batch_New__(
            contract_            => contract_,
            part_no_             => part_no_,
            png_                 => png_,
            ms_set_              => ms_set_,
            activity_seq_        => 0,
            ms_date_             => Work_Time_Calendar_API.Get_Next_Work_Day(calendar_id_, planning_tf_),
            parent_contract_     => NULL,
            parent_part_         => NULL,
            forecast_lev0_       => 0,
            forecast_lev1_       => 0,
            consumed_forecast_   => 0,
            actual_demand_       => 0,
            planned_demand_      => 0,
            supply_              => 0,
            consumed_supply_     => 0,
            firm_orders_         => 0,
            sched_orders_        => 0,
            rel_ord_rcpt_        => 0,
            master_sched_rcpt_   => 0,
            avail_to_prom_       => 0,
            roll_up_rcpt_        => NULL,
            net_avail_           => 0,
            proj_avail_          => 0,
            mtr_demand_qty_      => 0,
            mtr_supply_qty_      => 0,
            offset_              => NULL,
            sysgen_flag_         => Sysgen_API.Decode(sysgen_yes_),
            master_sched_status_ => Master_Sched_Status_API.Decode(Master_Sched_Status_API.DB_PROPOSED_MS_RECEIPT));
      END IF;
      Calculate_Ms_Receipt_ (
         part_no_                     => part_no_,
         contract_                    => contract_,
         png_                         => png_,
         ms_set_                      => ms_set_,
         ms_date_                     => run_date_,
         inventory_part_plan_rec_     => inventory_part_plan_rec_,
         qty_onhand_                  => qty_onhand_,
         demand_tf_                   => demand_tf_,
         planning_tf_                 => planning_tf_,
         roll_flag_db_                => roll_flag_db_,
         lead_time_code_db_           => inventory_part_rec_.lead_time_code,
         shop_order_proposal_flag_db_ => shop_order_proposal_flag_db_,
         create_fixed_ms_receipt_db_  => create_fixed_ms_receipt_db_,
         split_manuf_acquired_        => split_manuf_acquired_,
         is_part_internally_sourced_  => is_part_internally_sourced_,
         order_proposal_release_db_   => order_proposal_release_db_,
         manuf_supply_type_           => manuf_supply_type_,
         acquired_supply_type_        => acquired_supply_type_,
         pur_lu_req_exists_           => pur_lu_req_exists_,
         calendar_id_                 => calendar_id_,
         unit_meas_                   => inventory_part_rec_.unit_meas,
         stock_management_            => inventory_part_rec_.stock_management,
         min_date_                    => min_date_,
         max_date_                    => max_date_,
         start_crp_calc_              => start_crp_calc_);
   
      Calculate_Proj_Avail_ (
         contract_                 => contract_,
         part_no_                  => part_no_,
         png_                      => png_,
         ms_set_                   => ms_set_,
         qty_onhand_               => qty_onhand_,
         demand_tf_date_           => demand_tf_,
         planning_tf_date_         => planning_tf_,
         lead_time_code_db_        => inventory_part_rec_.lead_time_code );
   
      Update_Family_Info(contract_, part_no_, png_, ms_set_);
   
   EXCEPTION
      WHEN OTHERS THEN
         IF Error_SYS.Is_Foundation_Error(SQLCODE) THEN
            RAISE;
         END IF;
   
         local_contract_ := contract_ || ', Part No ' || part_no_;
   
         Error_Sys.Appl_General (lu_name_, 'INITIATE: Error :P1 occurred while running LEVEL_1_FORECAST_UTIL_API.Initiate_ for Site :P2 MS Set :P3.', SQLERRM, local_contract_, ms_set_);
   END Core;

BEGIN
   General_SYS.Init_Method(LEVEL_1_FORECAST_UTIL_API.lu_name_, 'LEVEL_1_FORECAST_UTIL_API', 'Initiate_');
   Core(contract_, part_no_, png_, ms_set_, run_date_, demand_tf_, planning_tf_, qty_onhand_, roll_flag_db_, shop_order_proposal_flag_db_, create_fixed_ms_receipt_db_, split_manuf_acquired_, is_part_internally_sourced_, order_proposal_release_db_, manuf_supply_type_, acquired_supply_type_, prev_run_date_, pur_lu_req_exists_, so_lu_prop_exists_, calendar_id_, min_date_, max_date_, start_crp_calc_);
END Initiate_;


PROCEDURE Calculate_Ms_Receipt_ (
   contract_                      IN VARCHAR2,
   part_no_                       IN VARCHAR2,
   png_                           IN VARCHAR2,
   ms_set_                        IN NUMBER,
   ms_date_                       IN DATE,
   inventory_part_plan_rec_       IN Inventory_Part_Planning_API.Public_Rec,
   qty_onhand_                    IN NUMBER,
   demand_tf_                     IN DATE,
   planning_tf_                   IN DATE,
   roll_flag_db_                  IN VARCHAR2,
   lead_time_code_db_             IN VARCHAR2,
   shop_order_proposal_flag_db_   IN VARCHAR2,
   create_fixed_ms_receipt_db_    IN VARCHAR2,
   split_manuf_acquired_          IN VARCHAR2,
   is_part_internally_sourced_    IN VARCHAR2,
   order_proposal_release_db_     IN VARCHAR2,
   manuf_supply_type_             IN VARCHAR2,
   acquired_supply_type_          IN VARCHAR2,
   pur_lu_req_exists_             IN BOOLEAN,
   calendar_id_                   IN VARCHAR2,
   unit_meas_                     IN VARCHAR2,
   stock_management_              IN VARCHAR2,
   min_date_                      IN DATE,
   max_date_                      IN DATE,
   start_crp_calc_                IN BOOLEAN )
IS
   
   PROCEDURE Core (
      contract_                      IN VARCHAR2,
      part_no_                       IN VARCHAR2,
      png_                           IN VARCHAR2,
      ms_set_                        IN NUMBER,
      ms_date_                       IN DATE,
      inventory_part_plan_rec_       IN Inventory_Part_Planning_API.Public_Rec,
      qty_onhand_                    IN NUMBER,
      demand_tf_                     IN DATE,
      planning_tf_                   IN DATE,
      roll_flag_db_                  IN VARCHAR2,
      lead_time_code_db_             IN VARCHAR2,
      shop_order_proposal_flag_db_   IN VARCHAR2,
      create_fixed_ms_receipt_db_    IN VARCHAR2,
      split_manuf_acquired_          IN VARCHAR2,
      is_part_internally_sourced_    IN VARCHAR2,
      order_proposal_release_db_     IN VARCHAR2,
      manuf_supply_type_             IN VARCHAR2,
      acquired_supply_type_          IN VARCHAR2,
      pur_lu_req_exists_             IN BOOLEAN,
      calendar_id_                   IN VARCHAR2,
      unit_meas_                     IN VARCHAR2,
      stock_management_              IN VARCHAR2,
      min_date_                      IN DATE,
      max_date_                      IN DATE,
      start_crp_calc_                IN BOOLEAN )
   IS
      level_1_part_rec_             Level_1_Part_API.Public_Rec := Level_1_Part_API.Get(contract_, part_no_, png_);
      first_iteration_              BOOLEAN;
      prev_rcpt_                    NUMBER;
      roll_up_date_                 DATE;
      proj_onhand_minus_ss_         NUMBER;
      proj_onhand_minus_tpss_       NUMBER;
      proj_onhand_                  NUMBER;
      total_increment_              NUMBER;
      net_avail_                    NUMBER;
      net_avail_flag_               BOOLEAN;
      local_contract_               VARCHAR2(200);
      local_forecast_lev0_          NUMBER;
      local_forecast_lev1_          NUMBER;
      fcst_adjustment_qty_          NUMBER;
      new_mps_                      NUMBER;
      pb_flag_                      BOOLEAN;
      do_supply_arr_                Supply_Collection;
      adjusted_increment_qty_       NUMBER := 0;
      applied_dis_ord_date_         DATE;
      prev_period_start_date_       DATE;
      period_end_date_              DATE;
      weekend_demand_after_ptf_     NUMBER;
      ssiilp_                       NUMBER;  -- Time phased Safety Stock Induced Inventory Last Period
      ssar_                         NUMBER;  -- Time phased Safety Stock Adjusted Requirement
      ssii_                         NUMBER;  -- Time phased Safety Stock Induced Inventory
      gen_ss_msg_                   BOOLEAN;
      gen_tpss_msg_                 BOOLEAN;
      idx_                          PLS_INTEGER;
      records_deleted_cnt_          PLS_INTEGER;
      
      --cr drp qs
      last_one_                     NUMBER;
      first_ms_date_                DATE;
      roll_up_temp_cnt_             NUMBER;
      roll_up_rcpt_temp_            NUMBER;
      first_iteration_temp_         BOOLEAN := TRUE;
      temp_                         NUMBER;
      maxweek_supply_               NUMBER := 0;
      proj_avail_                   NUMBER;
      i                             NUMBER;
      --
   
      CURSOR get_forecast_dates IS
         SELECT ms_date
         FROM level_1_forecast_tab
         WHERE part_no   = part_no_
         AND   contract  = contract_
         AND   png       = png_
         AND   ms_set    = ms_set_
         AND   ms_date  <= planning_tf_
         ORDER BY ms_date;
   
      CURSOR get_prev_rcpt IS
         SELECT NVL(roll_up_rcpt, 0)
         FROM level_1_forecast_tab
         WHERE part_no  = part_no_
         AND   contract = contract_
         AND   png      = png_
         AND   ms_set   = ms_set_
         AND   ms_date  = roll_up_date_;
      
      -- Below cursor selects supply and demand data but also all working days between Ptf and the last level_1_forecast record for the part and ms_set
      CURSOR new_mps IS
         SELECT wtc.work_day,
                wtc.counter,
                NVL(actual_demand,0) + NVL(planned_demand,0) +
                (NVL(forecast_lev1, 0) + NVL(forecast_lev0, 0) - NVL(consumed_forecast, 0)) +
                Level_1_Forecast_API.Get_Demand_During_Weekends_(contract_, part_no_, '*', ms_set_, 0, wtc.work_day, wtc.counter+1, wtc.calendar_id) demand,
                Strategic_Safe_Stock_Part_API.Get_Qty_For_Date_Adj_Prior_Wd(contract_, part_no_, wtc.work_day, wtc.calendar_id) time_phased_ss_level,
                NVL(firm_orders,0) + NVL(rel_ord_rcpt,0) + NVL(sched_orders,0) act_receipt,
                NVL(master_sched_rcpt,0) mps,
                0 projected_onhand,
                0 ms_receipt_activity_seq
         FROM work_time_calendar_pub wtc FULL outer join LEVEL_1_FORECAST_TAB l1fa
         ON (wtc.work_day  = l1fa.ms_date
         AND l1fa.part_no  = part_no_
         AND l1fa.contract = contract_
         AND l1fa.png      = png_
         AND l1fa.ms_set   = ms_set_
         AND l1fa.ms_date  > planning_tf_)
         WHERE wtc.calendar_id = calendar_id_
         AND wtc.work_day > planning_tf_
         AND wtc.work_day <= (SELECT max(l1fb.ms_date)
                              FROM LEVEL_1_FORECAST_TAB l1fb
                              WHERE l1fb.part_no  = part_no_
                              AND   l1fb.contract = contract_
                              AND   l1fb.png      = png_
                              AND   l1fb.ms_set   = ms_set_
                              AND   l1fb.ms_date  > planning_tf_)
         ORDER BY wtc.work_day;
      -- Below array will hold records selected by above cursor.
      new_mps_arr_       Mps_Array_; 
   
      CURSOR ms_zero IS
         SELECT ms_date
         FROM level_1_forecast_tab
         WHERE part_no                   = part_no_
         AND   contract                  = contract_
         AND   png                       = png_
         AND   ms_set                    = ms_set_
         AND   ms_date BETWEEN demand_tf_ AND planning_tf_
         AND   NVL(master_sched_rcpt, 0) > 0;
   
      CURSOR set_msrcpt_to_zero IS
         SELECT ms_date
         FROM level_1_forecast_tab
         WHERE part_no                   = part_no_
         AND   contract                  = contract_
         AND   png                       = png_
         AND   ms_set                    = ms_set_
         AND   ms_date                   < LEAST(demand_tf_, planning_tf_)
         AND   sysgen_flag               = sysgen_yes_
         AND   NVL(master_sched_rcpt, 0) > 0;
   
      CURSOR get_ms_sub_rcpt(parent_date_ DATE) IS
         SELECT line_no
         FROM ms_receipt_tab
         WHERE part_no  = part_no_
         AND   contract = contract_
         AND   png      = png_
         AND   ms_set   = ms_set_
         AND   ms_date  = parent_date_;
   
      CURSOR fxd_ms_rcpt IS
         SELECT ms_date
         FROM level_1_forecast_tab
         WHERE part_no                    = part_no_
         AND   contract                   = contract_
         AND   png                        = png_
         AND   ms_set                     = ms_set_
         AND   ms_date                    >= LEAST(demand_tf_, planning_tf_)
         AND   ms_date                    <= planning_tf_
         AND   NVL(master_sched_rcpt, 0)  > 0;
   
      CURSOR ms_msrcpt_to_zero2 IS
         SELECT ms_date
         FROM level_1_forecast_tab
         WHERE part_no                    = part_no_
         AND   contract                   = contract_
         AND   png                        = png_
         AND   ms_set                     = ms_set_
         AND   ms_date                   <= planning_tf_
         AND   sysgen_flag                = sysgen_yes_
         AND   NVL(master_sched_rcpt, 0)  > 0;
   
      CURSOR forecasts_inside_dtf IS
         SELECT ms_date, forecast_lev0, forecast_lev1, consumed_forecast
         FROM level_1_forecast_tab
         WHERE part_no    = part_no_
         AND   contract   = contract_
         AND   png        = png_
         AND   ms_set     = ms_set_
         AND   ms_date   <= demand_tf_
         AND   ( NVL(forecast_lev0,     0) > 0 OR
                 NVL(forecast_lev1,     0) > 0 OR
                 NVL(consumed_forecast, 0) > 0 );
   
      CURSOR fxd_ms_rcpts_inside_dtf IS
         SELECT ms_date
         FROM level_1_forecast_tab
         WHERE part_no    = part_no_
         AND   contract   = contract_
         AND   png        = png_
         AND   ms_set     = ms_set_
         AND   ms_date   <= demand_tf_
         AND   NVL(master_sched_rcpt, 0) > 0
         AND   sysgen_flag = sysgen_no_;
   
      CURSOR ms_rcpts_inside_dtf IS
         SELECT ms_date, line_no
         FROM ms_receipt_tab
         WHERE part_no    = part_no_
         AND   contract   = contract_
         AND   png        = png_
         AND   ms_set     = ms_set_
         AND   ms_date   <= demand_tf_
         AND   NVL(master_sched_rcpt, 0) > 0
         AND   sysgen_flag = sysgen_no_;
   
      -- This cursor should normally not return any rows. It is used to find unconnected sub-msreceipts within Planning Time Fence.
      CURSOR get_remaining_sub_ms_rcpts IS
         SELECT ms_date, line_no
         FROM ms_receipt_tab msr
         WHERE part_no      = part_no_
         AND   contract     = contract_
         AND   png          = png_
         AND   ms_set       = ms_set_
         AND   activity_seq = 0
         AND   ms_date      <= planning_tf_
         AND   NVL(master_sched_rcpt, 0) > 0
         AND NOT EXISTS (SELECT 1 
                         FROM level_1_forecast_tab l1f
                         WHERE l1f.contract     = contract_
                         AND   l1f.part_no      = part_no_
                         AND   l1f.png          = png_
                         AND   l1f.ms_set       = ms_set_
                         AND   l1f.activity_seq = 0
                         AND   l1f.ms_date      = msr.ms_date
                         AND   NVL(l1f.master_sched_rcpt, 0) > 0);
                         
        CURSOR get_first_count IS 
        SELECT MAX(MS_DATE)
        FROM   SOFT_DRP_MS_GROUP_TAB
        WHERE contract                  = contract_
        AND   part_no                   = part_no_
        AND   ms_set                    = ms_set_
        AND   group_id                  = 1;
   
        CURSOR get_last (temp_ms_date_ IN DATE)IS 
        SELECT group_id
        FROM   SOFT_DRP_MS_GROUP_TAB
        WHERE contract                  = contract_
        AND   part_no                   = part_no_
        AND   ms_set                    = ms_set_
        AND   ms_date                   = temp_ms_date_;
   
   BEGIN
   
      IF (create_fixed_ms_receipt_db_ = Fnd_Boolean_API.DB_TRUE) THEN
   
         FOR ms_rcpt_rec IN set_msrcpt_to_zero LOOP
   
            Level_1_Forecast_API.Batch_Modify__ (
               contract_            => contract_,
               part_no_             => part_no_,
               png_                 => png_,
               ms_set_              => ms_set_,
               activity_seq_        => 0,
               ms_date_             => ms_rcpt_rec.ms_date,
               parent_contract_     => NULL,
               parent_part_         => NULL,
               forecast_lev0_       => NULL,
               forecast_lev1_       => NULL,
               consumed_forecast_   => NULL,
               actual_demand_       => NULL,
               planned_demand_      => NULL,
               supply_              => NULL,
               consumed_supply_     => NULL,
               firm_orders_         => NULL,
               sched_orders_        => NULL,
               rel_ord_rcpt_        => NULL,
               master_sched_rcpt_   => 0,
               avail_to_prom_       => NULL,
               roll_up_rcpt_        => NULL,
               net_avail_           => NULL,
               proj_avail_          => NULL,
               mtr_demand_qty_      => NULL,
               mtr_supply_qty_      => NULL,
               offset_              => NULL,
               roll_flag_db_        => NULL,
               sysgen_flag_         => NULL,
               master_sched_status_ => NULL,
               method_              => 'UPDATE' );
            
            FOR cursor_rec IN get_ms_sub_rcpt(ms_rcpt_rec.ms_date) LOOP
               Ms_Receipt_API.Batch_Remove__(
                  contract_,
                  part_no_,
                  png_,
                  ms_set_,
                  ms_rcpt_rec.ms_date,
                  cursor_rec.line_no);
            END LOOP;
   
         END LOOP;
   
         FOR fxd_ms_rcpt_rec IN fxd_ms_rcpt LOOP
         -- The records here have been aged within planning TF.
         -- Create fixed master schedule receipts.
            Level_1_Forecast_API.Batch_Modify__ (
               contract_            => contract_,
               part_no_             => part_no_,
               png_                 => png_,
               ms_set_              => ms_set_,
               activity_seq_        => 0,
               ms_date_             => fxd_ms_rcpt_rec.ms_date,
               parent_contract_     => NULL,
               parent_part_         => NULL,
               forecast_lev0_       => NULL,
               forecast_lev1_       => NULL,
               consumed_forecast_   => NULL,
               actual_demand_       => NULL,
               planned_demand_      => NULL,
               supply_              => NULL,
               consumed_supply_     => NULL,
               firm_orders_         => NULL,
               sched_orders_        => NULL,
               rel_ord_rcpt_        => NULL,
               master_sched_rcpt_   => NULL,
               avail_to_prom_       => NULL,
               roll_up_rcpt_        => NULL,
               net_avail_           => NULL,
               proj_avail_          => NULL,
               mtr_demand_qty_      => NULL,
               mtr_supply_qty_      => NULL,
               offset_              => NULL,
               roll_flag_db_        => NULL,
               sysgen_flag_         => sysgen_no_,
               master_sched_status_ => Master_Sched_Status_API.DB_FIXED_MS_RECEIPT,
               method_              => 'UPDATE' );
   
            FOR cursor_rec IN get_ms_sub_rcpt(fxd_ms_rcpt_rec.ms_date) LOOP
               Ms_Receipt_API.Batch_Modify__(
                  contract_               => contract_,
                  part_no_                => part_no_,
                  png_                    => png_,
                  ms_set_                 => ms_set_,
                  activity_seq_           => 0,
                  ms_date_                => fxd_ms_rcpt_rec.ms_date,
                  line_no_                => cursor_rec.line_no,
                  master_sched_rcpt_      => NULL,
                  sysgen_flag_            => sysgen_no_,
                  method_                 => 'UPDATE');
   
            END LOOP;
   
         END LOOP;
   
      ELSE  -- Do not create fixed ms rcpt automatically!
   
         FOR ms_rcpt_rec IN ms_msrcpt_to_zero2 LOOP
            -- Update proposed master schedule receipts inside PTF to zero.
            Level_1_Forecast_API.Batch_Modify__ (
               contract_            => contract_,
               part_no_             => part_no_,
               png_                 => png_,
               ms_set_              => ms_set_,
               activity_seq_        => 0,
               ms_date_             => ms_rcpt_rec.ms_date,
               parent_contract_     => NULL,
               parent_part_         => NULL,
               forecast_lev0_       => NULL,
               forecast_lev1_       => NULL,
               consumed_forecast_   => NULL,
               actual_demand_       => NULL,
               planned_demand_      => NULL,
               supply_              => NULL,
               consumed_supply_     => NULL,
               firm_orders_         => NULL,
               sched_orders_        => NULL,
               rel_ord_rcpt_        => NULL,
               master_sched_rcpt_   => 0,
               avail_to_prom_       => NULL,
               roll_up_rcpt_        => NULL,
               net_avail_           => NULL,
               proj_avail_          => NULL,
               mtr_demand_qty_      => NULL,
               mtr_supply_qty_      => NULL,
               offset_              => NULL,
               roll_flag_db_        => NULL,
               sysgen_flag_         => NULL,
               master_sched_status_ => NULL,
               method_              => 'UPDATE' );
            
            FOR cursor_rec IN get_ms_sub_rcpt(ms_rcpt_rec.ms_date) LOOP
               Ms_Receipt_API.Batch_Remove__(
                  contract_,
                  part_no_,
                  png_,
                  ms_set_,
                  ms_rcpt_rec.ms_date,
                  cursor_rec.line_no);
            END LOOP;
         END LOOP;
   
      END IF;
   
      FOR fxd_ms_rcpts_inside_dtf_rec IN fxd_ms_rcpts_inside_dtf LOOP
         Level_1_Forecast_API.Batch_Modify__ (
            contract_            => contract_,
            part_no_             => part_no_,
            png_                 => png_,
            ms_set_              => ms_set_,
            activity_seq_        => 0,
            ms_date_             => fxd_ms_rcpts_inside_dtf_rec.ms_date,
            parent_contract_     => NULL,
            parent_part_         => NULL,
            forecast_lev0_       => NULL,
            forecast_lev1_       => NULL,
            consumed_forecast_   => NULL,
            actual_demand_       => NULL,
            planned_demand_      => NULL,
            supply_              => NULL,
            consumed_supply_     => NULL,
            firm_orders_         => NULL,
            sched_orders_        => NULL,
            rel_ord_rcpt_        => NULL,
            master_sched_rcpt_   => 0,
            avail_to_prom_       => NULL,
            roll_up_rcpt_        => NULL,
            net_avail_           => NULL,
            proj_avail_          => NULL,
            mtr_demand_qty_      => NULL,
            mtr_supply_qty_      => NULL,
            offset_              => NULL,
            roll_flag_db_        => NULL,
            sysgen_flag_         => NULL,
            master_sched_status_ => NULL,
            method_              => 'UPDATE' );
         
      END LOOP;
      
      FOR ms_rcpts_inside_dtf_rec IN ms_rcpts_inside_dtf LOOP
         Ms_Receipt_API.Batch_Remove__(contract_,
                                       part_no_,
                                       png_,
                                       ms_set_,
                                       ms_rcpts_inside_dtf_rec.ms_date,
                                       ms_rcpts_inside_dtf_rec.line_no);
      END LOOP;
      
      FOR ms_rcpts_rec IN get_remaining_sub_ms_rcpts LOOP
         Ms_Receipt_API.Batch_Remove__(contract_,
                                       part_no_,
                                       png_,
                                       ms_set_,
                                       ms_rcpts_rec.ms_date,
                                       ms_rcpts_rec.line_no);
      END LOOP;
   
      -- The table PEGGED_SUPPLY_DEMAND_TAB is loaded with values from the view SUPPLY_DEMAND_MS.
      Pegged_Supply_Demand_Util_API.Insert_Orders__ (contract_, part_no_, png_, ms_set_);
   
      Pegged_Supply_Demand_Util_API.Calculate_Massch_Info__(contract_, part_no_, png_, ms_set_);
   
      -- Shop Order Proposals, or Purchase Requisitions, or Production
      -- Schedules are created of those fixed Master Schedule Receipts
      -- which are inside the planning timefence.
   
      IF (ms_set_ = 1 AND order_proposal_release_db_ = 'RELEASE' AND shop_order_proposal_flag_db_ IN ('Y','H')) THEN
         Generate_Supply___(
            applied_dis_ord_date_,
            adjusted_increment_qty_,
            do_supply_arr_,
            contract_,
            part_no_,
            png_,
            ms_set_,
            split_manuf_acquired_,
            min_date_,
            planning_tf_,
            calendar_id_,
            unit_meas_,
            is_part_internally_sourced_,
            manuf_supply_type_,
            pur_lu_req_exists_,
            ms_date_,
            acquired_supply_type_,
            stock_management_,
            lead_time_code_db_,
            inventory_part_plan_rec_.order_requisition,
            start_crp_calc_);
      END IF;
      Recalc_Consumed_Fcst__(contract_, part_no_, png_, ms_set_, level_1_part_rec_.ms_receipt_activity_seq, FALSE, '??', --> Batch process will not use source_type_
                             level_1_part_rec_.promise_method,
                             calendar_id_,
                             NVL(level_1_part_rec_.forecast_consumption_wnd, 0),
                             NVL(level_1_part_rec_.fwd_forecast_consumption, 0)); 
   
      IF (level_1_part_rec_.unconsumed_forecast_disp = '2') THEN -- if rollout unconsumed forecast within dtf
   
         Rollout_Unconsumed_Fcst__ (
            contract_,
            part_no_,
            png_,
            ms_set_,
            level_1_part_rec_.ms_receipt_activity_seq,
            dtf_date_ => demand_tf_,
            calendar_id_ => calendar_id_,
            max_unconsumed_fcst_ => level_1_part_rec_.max_unconsumed_forecast,
            roll_by_percentage_ => level_1_part_rec_.roll_by_percentage,
            roll_window_ => level_1_part_rec_.roll_window);
   
      END IF;
   
      -- adjust existing forecasts inside DTF.
      FOR forecasts_inside_dtf_rec IN forecasts_inside_dtf LOOP
   
         fcst_adjustment_qty_ := 0;
         local_forecast_lev0_ := NULL;
         local_forecast_lev1_ := NULL;
   
         IF ( NVL(forecasts_inside_dtf_rec.forecast_lev0, 0) +
              NVL(forecasts_inside_dtf_rec.forecast_lev1, 0) >
              NVL(forecasts_inside_dtf_rec.consumed_forecast, 0) ) THEN
   
            fcst_adjustment_qty_ := NVL(forecasts_inside_dtf_rec.forecast_lev0, 0) +
                                    NVL(forecasts_inside_dtf_rec.forecast_lev1, 0) -
                                    NVL(forecasts_inside_dtf_rec.consumed_forecast, 0);
   
            -- adjust forecasts, level 1 forecast first, for unconsumed qty.
            IF (fcst_adjustment_qty_ > 0) THEN
   
               IF (forecasts_inside_dtf_rec.forecast_lev1 IS NOT NULL) THEN
                  IF (fcst_adjustment_qty_ > forecasts_inside_dtf_rec.forecast_lev1) THEN
                     local_forecast_lev1_ := 0;
                  ELSE
                     local_forecast_lev1_ := forecasts_inside_dtf_rec.forecast_lev1 - fcst_adjustment_qty_;
                  END IF;
                  fcst_adjustment_qty_ := GREATEST(0, fcst_adjustment_qty_ - forecasts_inside_dtf_rec.forecast_lev1);
               END IF;
   
               IF (forecasts_inside_dtf_rec.forecast_lev0 IS NOT NULL) THEN
                  IF (fcst_adjustment_qty_ > forecasts_inside_dtf_rec.forecast_lev0) THEN
                     local_forecast_lev0_ := 0;
                  ELSE
                     local_forecast_lev0_ := forecasts_inside_dtf_rec.forecast_lev0 - fcst_adjustment_qty_;
                  END IF;
               END IF;
            END IF;
         END IF;
   
         Level_1_Forecast_API.Batch_Modify__ (
            contract_            => contract_,
            part_no_             => part_no_,
            png_                 => png_,
            ms_set_              => ms_set_,
            activity_seq_        => 0,
            ms_date_             => forecasts_inside_dtf_rec.ms_date,
            parent_contract_     => NULL,
            parent_part_         => NULL,
            forecast_lev0_       => local_forecast_lev0_,
            forecast_lev1_       => local_forecast_lev1_,
            consumed_forecast_   => NULL,
            actual_demand_       => NULL,
            planned_demand_      => NULL,
            supply_              => NULL,
            consumed_supply_     => NULL,
            firm_orders_         => NULL,
            sched_orders_        => NULL,
            rel_ord_rcpt_        => NULL,
            master_sched_rcpt_   => NULL,
            avail_to_prom_       => NULL,
            roll_up_rcpt_        => NULL,
            net_avail_           => NULL,
            proj_avail_          => NULL,
            mtr_demand_qty_      => NULL,
            mtr_supply_qty_      => NULL,
            offset_              => NULL,
            roll_flag_db_        => NULL,
            sysgen_flag_         => NULL,
            master_sched_status_ => NULL,
            method_              => 'UPDATE' );
   
      END LOOP;
   
      -- Start the roll up of projected onhand from past due to PTF
      net_avail_      := 0;
      ssiilp_         := 0;
      net_avail_flag_ := TRUE;
      pb_flag_        := TRUE;
      gen_ss_msg_     := TRUE;
      gen_tpss_msg_   := TRUE;
      prev_period_start_date_ := Strategic_Safe_Stock_Part_API.Get_Prev_Period_Start_Date(contract_, part_no_, planning_tf_+1);
      period_end_date_ := Strategic_Safe_Stock_Part_API.Get_Period_End_Date(contract_, part_no_, prev_period_start_date_);
      IF (prev_period_start_date_ IS NOT NULL AND planning_tf_ < period_end_date_) THEN
         ssiilp_ := Strategic_Safe_Stock_Part_API.Get_Build_Up_Qty_For_Period(contract_, part_no_, prev_period_start_date_);
         IF NOT Level_1_Forecast_API.Check_Exist(contract_, part_no_, png_, ms_set_, 0, prev_period_start_date_) THEN
            -- Create a zero record for the date that Time Phased SS is cut in
            Level_1_Forecast_API.Batch_New__(
               contract_            => contract_,
               part_no_             => part_no_,
               png_                 => png_,
               ms_set_              => ms_set_,
               activity_seq_        => 0,
               ms_date_             => prev_period_start_date_,
               parent_contract_     => NULL,
               parent_part_         => NULL,
               forecast_lev0_       => 0,
               forecast_lev1_       => 0,
               consumed_forecast_   => 0,
               actual_demand_       => 0,
               planned_demand_      => 0,
               supply_              => 0,
               consumed_supply_     => 0,
               firm_orders_         => 0,
               sched_orders_        => 0,
               rel_ord_rcpt_        => 0,
               master_sched_rcpt_   => 0,
               avail_to_prom_       => 0,
               roll_up_rcpt_        => NULL,
               net_avail_           => 0,
               proj_avail_          => 0,
               mtr_demand_qty_      => 0,
               mtr_supply_qty_      => 0,
               offset_              => NULL,
               sysgen_flag_         => Sysgen_API.Decode(sysgen_yes_),
               master_sched_status_ => Master_Sched_Status_API.Decode(Master_Sched_Status_API.DB_PROPOSED_MS_RECEIPT));
         END IF;     
      END IF;   
      
      
      
      proj_onhand_minus_ss_ := NVL(qty_onhand_,0) - NVL(inventory_part_plan_rec_.safety_stock, 0);
      proj_onhand_minus_tpss_ := proj_onhand_minus_ss_;
      total_increment_ := 0;
      proj_onhand_     := NVL(qty_onhand_,0);
   
      --cr drp qs
      IF(inventory_part_plan_rec_.planning_method = 'G' 
         and SOft_DRp_Site_Api.Exist_(contract_)) THEN
       
         DELETE FROM SOFT_DRP_MS_GROUP_TAB 
         WHERE ms_date > planning_tf_;
       
         OPEN get_first_count;
         FETCH get_first_count into first_ms_date_;
         CLOSE get_first_count;
       
         maxweek_supply_  := nvl(inventory_part_plan_rec_.maxweek_supply,0); --5 
       
         if first_ms_date_ IS NOT NULL THEN 
            last_one_ := NVL(greatest((planning_tf_+1) - first_ms_date_ , 0),0) + 1;
         
            if(last_one_ > maxweek_supply_) THEN
                last_one_ := 1;
            end if;
        
         else
            last_one_ := 1;
         --insert into soft_drp_ms_group_tab(contract, part_no, ms_set, counter, group_id, rowversion) values (contract_, part_no_, ms_set_, period_2_ + 1, last_one_ , sysdate);
         END IF;
      END IF;
      --cr
      
      FOR forecast_rec IN get_forecast_dates LOOP  
   
         roll_up_date_ := forecast_rec.ms_date;    
   
         Level_1_Onhand_Util_API.Increment_Qty_Onhand_(
            total_increment_,
            contract_,
            part_no_,
            png_,
            ms_set_,
            0,
            forecast_rec.ms_date,
            demand_tf_,
            planning_tf_ );
         
         proj_onhand_minus_ss_ := proj_onhand_minus_ss_ - total_increment_;
   
         IF prev_period_start_date_ = forecast_rec.ms_date THEN
            proj_onhand_minus_tpss_ := proj_onhand_minus_tpss_ - total_increment_ - ssiilp_;
         ELSE
            proj_onhand_minus_tpss_ := proj_onhand_minus_tpss_ - total_increment_;
         END IF;
         
         proj_onhand_ := proj_onhand_ - total_increment_;
         
         IF proj_onhand_minus_ss_ < 0 AND gen_ss_msg_ THEN
            IF NVL(inventory_part_plan_rec_.safety_stock, 0) > 0 THEN
               gen_ss_msg_ := FALSE;
               -- Projected Balance is below Safety Stock.
               Level_1_Message_API.Batch_New__(
                   contract_        => contract_,
                   part_no_         => part_no_,
                   png_             => png_,
                   ms_set_          => ms_set_,
                   ms_date_         => forecast_rec.ms_date,
                   order_no_        => NULL,
                   line_no_         => NULL,
                   release_no_      => NULL,
                   line_item_no_    => NULL,
                   order_type_db_   => NULL,
                   activity_seq_    => NULL,
                   msg_code_        => 'E536');
            END IF;
         END IF;
         
         IF proj_onhand_minus_tpss_ < 0 AND net_avail_flag_ THEN
            net_avail_ := -1;
            net_avail_flag_ := FALSE;
         END IF;
            
         IF proj_onhand_minus_tpss_ < 0 AND ssiilp_ > 0 AND gen_tpss_msg_ THEN
            gen_tpss_msg_ := FALSE;
            --Projected Balance is below time phased safety stock + safety stock
            Level_1_Message_API.Batch_New__(
                contract_        => contract_,
                part_no_         => part_no_,
                png_             => png_,
                ms_set_          => ms_set_,
                ms_date_         => prev_period_start_date_,
                order_no_        => NULL,
                line_no_         => NULL,
                release_no_      => NULL,
                line_item_no_    => NULL,
                order_type_db_   => NULL,
                activity_seq_    => NULL,
                msg_code_        => 'E549');
         END IF; 
         
         
         IF (proj_onhand_ < 0 AND pb_flag_) THEN
            pb_flag_ := FALSE;
            -- Projected Balance negative.
            Level_1_Message_API.Batch_New__(
                contract_        => contract_,
                part_no_         => part_no_,
                png_             => png_,
                ms_set_          => ms_set_,
                ms_date_         => forecast_rec.ms_date,
                order_no_        => NULL,
                line_no_         => NULL,
                release_no_      => NULL,
                line_item_no_    => NULL,
                order_type_db_   => NULL,
                activity_seq_    => NULL,
                msg_code_        => 'E515');
         END IF;
   
      END LOOP;
   
      -- Special handling for DO supply that might have been moved outside PTF
      IF adjusted_increment_qty_ > 0 THEN
         proj_onhand_minus_tpss_ := proj_onhand_minus_tpss_ + Inventory_Part_Planning_API.Get_Scrap_Removed_Qty(contract_,
                                                                                                            part_no_,
                                                                                                            adjusted_increment_qty_);
      END IF;
   
      -- Net avail = Used to indicate if available has been below zero.
      Level_1_Forecast_API.Batch_Modify__ (
         contract_            => contract_,
         part_no_             => part_no_,
         png_                 => png_,
         ms_set_              => ms_set_,
         activity_seq_        => 0,
         ms_date_             => roll_up_date_,
         parent_contract_     => NULL,
         parent_part_         => NULL,
         forecast_lev0_       => NULL,
         forecast_lev1_       => NULL,
         consumed_forecast_   => NULL,
         actual_demand_       => NULL,
         planned_demand_      => NULL,
         supply_              => NULL,
         consumed_supply_     => NULL,
         firm_orders_         => NULL,
         sched_orders_        => NULL,
         rel_ord_rcpt_        => NULL,
         master_sched_rcpt_   => NULL,
         avail_to_prom_       => NULL,
         roll_up_rcpt_        => proj_onhand_minus_tpss_,
         net_avail_           => net_avail_,
         proj_avail_          => NULL,
         mtr_demand_qty_      => NULL,
         mtr_supply_qty_      => NULL,
         offset_              => NULL,
         roll_flag_db_        => Fnd_Boolean_API.DB_TRUE,
         sysgen_flag_         => NULL,
         master_sched_status_ => NULL,
         method_              => 'UPDATE' );
   
      -- end roll up of projected onhand to PTF
   
      IF (proj_onhand_minus_tpss_ < 0) THEN
         IF (NOT Level_1_Forecast_API.Check_Exist(
                               contract_, part_no_, png_, ms_set_, 0,
                               Trunc(Work_Time_Calendar_API.Get_Next_Work_Day(calendar_id_,planning_tf_)))) THEN
   
            Level_1_Forecast_API.Batch_New__(
               contract_            => contract_,
               part_no_             => part_no_,
               png_                 => png_,
               ms_set_              => ms_set_,
               activity_seq_        => 0,
               ms_date_             => Work_Time_Calendar_API.Get_Next_Work_Day(calendar_id_,planning_tf_),
               parent_contract_     => NULL,
               parent_part_         => NULL,
               forecast_lev0_       => 0,
               forecast_lev1_       => 0,
               consumed_forecast_   => 0,
               actual_demand_       => 0,
               planned_demand_      => 0,
               supply_              => 0,
               consumed_supply_     => 0,
               firm_orders_         => 0,
               sched_orders_        => 0,
               rel_ord_rcpt_        => 0,
               master_sched_rcpt_   => 0,
               avail_to_prom_       => 0,
               roll_up_rcpt_        => 0,
               net_avail_           => 0,
               proj_avail_          => 0,
               mtr_demand_qty_      => 0,
               mtr_supply_qty_      => 0,
               offset_              => NULL,
               sysgen_flag_         => Sysgen_API.Decode(sysgen_yes_),
               master_sched_status_ => Master_Sched_Status_API.Decode(Master_Sched_Status_API.DB_PROPOSED_MS_RECEIPT));
         END IF;
      END IF;
   
      first_iteration_ := TRUE;
      prev_rcpt_       := 0;
      
      first_iteration_temp_ := TRUE;
      i                := 0;
      
      OPEN new_mps;
      FETCH new_mps BULK COLLECT INTO new_mps_arr_;
      CLOSE new_mps;
      
      idx_ := new_mps_arr_.FIRST;
      WHILE (idx_ IS NOT NULL) LOOP
         records_deleted_cnt_ := 0;
         Check_For_Zero_Rate___ (new_mps_arr_, records_deleted_cnt_, idx_, contract_, part_no_, png_);
         idx_ := new_mps_arr_.NEXT(idx_- records_deleted_cnt_);
      END LOOP;
      
      -- FOR row_index IN new_mps_arr_.FIRST .. new_mps_arr_.LAST LOOP      
      --   Trace_SYS.Message('row_index ='||row_index ||' '||new_mps_arr_(row_index).work_day);
      -- END LOOP;
         
      -- Create initial projected onhand development outside Ptf BEGIN
      FOR row_index IN new_mps_arr_.FIRST .. new_mps_arr_.LAST LOOP
         -- Calculation of how demand gets affected by time phased safety stock.
         IF first_iteration_ THEN
            weekend_demand_after_ptf_ := Level_1_Forecast_API.Get_Demand_During_Weekends_(contract_, part_no_, png_, ms_set_, 0, planning_tf_,
                                                                                          Work_Time_Calendar_API.Get_Work_Day_Counter(calendar_id_, planning_tf_) + 1,
                                                                                          calendar_id_);
            new_mps_arr_(row_index).demand := new_mps_arr_(row_index).demand + weekend_demand_after_ptf_;
         END IF;
         
         ssar_ := Greatest(new_mps_arr_(row_index).demand + new_mps_arr_(row_index).time_phased_ss_level - ssiilp_, 0);
         ssii_ := Greatest(ssiilp_ - new_mps_arr_(row_index).demand, new_mps_arr_(row_index).time_phased_ss_level);
         ssiilp_ := ssii_;
         
         IF first_iteration_ THEN
            --  This section is executed only once per part. If ROLL_FLAG is activated
            --  the rolling of previous onhand analysis are done below.
            IF (roll_flag_db_ = Fnd_Boolean_API.DB_TRUE) THEN
                OPEN get_prev_rcpt;
                FETCH get_prev_rcpt INTO prev_rcpt_;
                IF (get_prev_rcpt%NOTFOUND) THEN
                   prev_rcpt_ := 0;
                END IF;
                CLOSE get_prev_rcpt;
            END IF;
            
            IF(last_one_ > 1 AND last_one_ <= maxweek_supply_) THEN
                 new_mps_arr_(row_index).mps := 0;
            ELSE
                 temp_ := 0;
                 FOR i IN last_one_ + 1 .. maxweek_supply_ LOOP
                     temp_ := temp_ + new_mps_arr_(row_index+i).mps;
                 END LOOP;
                 new_mps_arr_(row_index).mps := new_mps_arr_(row_index).mps + temp_; 
          
                 IF new_mps_arr_(row_index).mps >= prev_rcpt_ THEN
                   new_mps_arr_(row_index).mps := new_mps_arr_(row_index).mps - prev_rcpt_;
                   prev_rcpt_         := 0;
                 ELSE
                   prev_rcpt_         := prev_rcpt_ - new_mps_arr_(row_index).mps ;
                   new_mps_arr_(row_index).mps  := 0;
                 END IF;
            END IF;   
               
            insert into soft_drp_ms_group_tab (contract, part_no, ms_set, ms_date, group_id, rowversion)
            VALUES (contract_, part_no_, ms_set_, new_mps_arr_(row_index).work_day, last_one_, sysdate);
      
            last_one_ := last_one_ +1;
      
            if(last_one_ > maxweek_supply_) THEN
              last_one_ := 1;
            end if;
            
            IF new_mps_arr_(row_index).mps > 0 THEN 
               new_mps_arr_(row_index).projected_onhand := prev_rcpt_ - ssar_ + new_mps_arr_(row_index).act_receipt +
                                                           GREATEST(new_mps_arr_(row_index).mps -
                                                           Inventory_Part_Planning_API.Get_Scrap_Removed_Qty(contract_,
                                                                                                             part_no_,
                                                                                                             Supply_Order_Detail_API.Get_Supply_Converted_To_Order(
                                                                                                                           contract_,
                                                                                                                           part_no_,
                                                                                                                           png_,
                                                                                                                           ms_set_,
                                                                                                                           new_mps_arr_(row_index).work_day)), 0);
               
            ELSE
               new_mps_arr_(row_index).projected_onhand := prev_rcpt_ - ssar_ + new_mps_arr_(row_index).act_receipt;
            END IF;
            first_iteration_ := FALSE;
         ELSE
            IF(last_one_ > 1 AND last_one_ <= maxweek_supply_) THEN
                 new_mps_arr_(row_index).mps := 0;
            ELSE
                 temp_ := 0;
                 FOR i IN last_one_ + 1 .. maxweek_supply_ LOOP
                     temp_ := temp_ + new_mps_arr_(row_index+i).mps;
                 END LOOP;
                 new_mps_arr_(row_index).mps := new_mps_arr_(row_index).mps + temp_; 
          
                 IF new_mps_arr_(row_index).mps >= prev_rcpt_ THEN
                   new_mps_arr_(row_index).mps := new_mps_arr_(row_index).mps - prev_rcpt_;
                   prev_rcpt_         := 0;
                 ELSE
                   prev_rcpt_         := prev_rcpt_ - new_mps_arr_(row_index).mps ;
                   new_mps_arr_(row_index).mps  := 0;
                 END IF;
            END IF;   
               
            insert into soft_drp_ms_group_tab (contract, part_no, ms_set, ms_date, group_id, rowversion)
            VALUES (contract_, part_no_, ms_set_, new_mps_arr_(row_index).work_day, last_one_, sysdate);
      
            last_one_ := last_one_ +1;
      
            if(last_one_ > maxweek_supply_) THEN
              last_one_ := 1;
            end if;
            
            IF new_mps_arr_(row_index).mps > 0 THEN 
               new_mps_arr_(row_index).projected_onhand := new_mps_arr_(row_index-1).projected_onhand - ssar_ + new_mps_arr_(row_index).act_receipt +
                                                           GREATEST(new_mps_arr_(row_index).mps -
                                                           Inventory_Part_Planning_API.Get_Scrap_Removed_Qty(contract_,
                                                                                                             part_no_,
                                                                                                             Supply_Order_Detail_API.Get_Supply_Converted_To_Order(
                                                                                                                           contract_,
                                                                                                                           part_no_,
                                                                                                                           png_,
                                                                                                                           ms_set_,
                                                                                                                           new_mps_arr_(row_index).work_day)), 0);
               
            ELSE
               new_mps_arr_(row_index).projected_onhand := new_mps_arr_(row_index-1).projected_onhand - ssar_ + new_mps_arr_(row_index).act_receipt;
            END IF;
         END IF;
         
         -- Special handling for DO supply that might have been moved outside PTF
         IF adjusted_increment_qty_ > 0 AND applied_dis_ord_date_ = new_mps_arr_(row_index).work_day THEN
            -- Here it is time to reduce projected onhand with the moved DO supply
            new_mps_arr_(row_index).projected_onhand := new_mps_arr_(row_index).projected_onhand -
                                                        Inventory_Part_Planning_API.Get_Scrap_Removed_Qty(contract_,
                                                                                                          part_no_,
                                                                                                          adjusted_increment_qty_);
         END IF;
         -- Trace_Sys.Message('Projected onhand development: '||new_mps_arr_(row_index).work_day||' '||new_mps_arr_(row_index).projected_onhand);
      END LOOP;
      -- Create initial projected onhand development outside Ptf END
            
      FOR row_index IN new_mps_arr_.FIRST .. new_mps_arr_.LAST LOOP      
         IF new_mps_arr_(row_index).projected_onhand < 0 THEN
            -- We have a net requirement
            -- Use scrapping algorithm with inventory scrap factor (shrinkage_factor)
            -- to increase supply
            new_mps_ := ABS(new_mps_arr_(row_index).projected_onhand) / (1 - (inventory_part_plan_rec_.shrinkage_fac / 100));
            
            Lot_Size_And_Create_New_Mps___(new_mps_arr_, row_index, new_mps_, contract_, part_no_, png_, ms_set_, planning_tf_, calendar_id_, inventory_part_plan_rec_, start_crp_calc_,
                                           shop_order_proposal_flag_db_, lead_time_code_db_);
            -- The new_mps_arr_.projected_onhand is recalculated in above call
         END IF;   
      END LOOP;
      
      IF (ms_set_ = 1 AND order_proposal_release_db_ = 'RELEASE' AND shop_order_proposal_flag_db_ = 'H') THEN
         Generate_Supply___(
            applied_dis_ord_date_,
            adjusted_increment_qty_,
            do_supply_arr_,
            contract_,
            part_no_,
            png_,
            ms_set_,
            split_manuf_acquired_,
            Work_Time_Calendar_API.Get_Next_Work_Day(calendar_id_, planning_tf_),
            max_date_,
            calendar_id_,
            unit_meas_,
            is_part_internally_sourced_,
            manuf_supply_type_,
            pur_lu_req_exists_,
            ms_date_,
            acquired_supply_type_,
            stock_management_,
            lead_time_code_db_,
            inventory_part_plan_rec_.order_requisition,
            start_crp_calc_);
      END IF;
      -- The MS-receipt is within planning timefence.
      FOR ms_rec IN ms_zero LOOP
         Level_1_Message_API.Batch_New__(
            contract_      => contract_,
            part_no_       => part_no_,
            png_           => png_,
            ms_set_        => ms_set_,
            ms_date_       => ms_rec.ms_date,
            order_no_      => NULL,
            line_no_       => NULL,
            release_no_    => NULL,
            line_item_no_  => NULL,
            order_type_db_ => NULL,
            activity_seq_  => NULL,
            msg_code_      => 'E525');      
      END LOOP;
   
      Recalc_Level1_Supply__(contract_, part_no_, png_, ms_set_,
                             ms_date_, demand_tf_, planning_tf_, NVL(qty_onhand_,0));
   
      Recalc_Consumed_Supply__(
         contract_                 => contract_,
         part_no_                  => part_no_,
         png_                      => png_,
         ms_set_                   => ms_set_,
         consuming_fcst_online_    => FALSE,
         source_type_              => '??',
         promise_method_db_        => level_1_part_rec_.promise_method,
         calendar_id_              => calendar_id_,
         order_line_cancellation_  => FALSE);
   
      Level_1_Onhand_Util_API.Calc_Avail_To_Promise_(contract_, part_no_, png_, ms_set_, ms_date_);
   
   EXCEPTION
      WHEN OTHERS THEN
         IF Error_SYS.Is_Foundation_Error(SQLCODE) THEN
            RAISE;
         END IF;
   
         local_contract_ := contract_ || ', Part No ' || part_no_;
   
         Error_Sys.Appl_General (lu_name_, 'CALCMSRCPT: Error :P1 occurred while running LEVEL_1_FORECAST_UTIL_API.Calculate_Ms_Receipt_ for Site :P2 MS Set :P3.', SQLERRM, local_contract_, ms_set_);
   END Core;

BEGIN
   General_SYS.Init_Method(LEVEL_1_FORECAST_UTIL_API.lu_name_, 'LEVEL_1_FORECAST_UTIL_API', 'Calculate_Ms_Receipt_');
   Core(contract_, part_no_, png_, ms_set_, ms_date_, inventory_part_plan_rec_, qty_onhand_, demand_tf_, planning_tf_, roll_flag_db_, lead_time_code_db_, shop_order_proposal_flag_db_, create_fixed_ms_receipt_db_, split_manuf_acquired_, is_part_internally_sourced_, order_proposal_release_db_, manuf_supply_type_, acquired_supply_type_, pur_lu_req_exists_, calendar_id_, unit_meas_, stock_management_, min_date_, max_date_, start_crp_calc_);
END Calculate_Ms_Receipt_;


PROCEDURE Calculate_Proj_Avail_ (
   contract_              IN VARCHAR2,
   part_no_               IN VARCHAR2,
   png_                   IN VARCHAR2,
   ms_set_                IN NUMBER,
   qty_onhand_            IN NUMBER,
   demand_tf_date_        IN DATE,
   planning_tf_date_      IN DATE,
   lead_time_code_db_     IN VARCHAR2 )
IS
   
   PROCEDURE Core (
      contract_              IN VARCHAR2,
      part_no_               IN VARCHAR2,
      png_                   IN VARCHAR2,
      ms_set_                IN NUMBER,
      qty_onhand_            IN NUMBER,
      demand_tf_date_        IN DATE,
      planning_tf_date_      IN DATE,
      lead_time_code_db_     IN VARCHAR2 )
   IS
      proj_avail_            NUMBER := NVL(qty_onhand_, 0);
      local_contract_        VARCHAR2(200);
      total_increment_       NUMBER;
   
      CURSOR get_proj_avail_dates IS
         SELECT ms_date
         FROM level_1_forecast_tab
         WHERE part_no = part_no_
         AND contract  = contract_
         AND png       = png_
         AND ms_set    = ms_set_
         ORDER BY ms_date;
   
   BEGIN
   
      FOR proj_avail_rec IN get_proj_avail_dates LOOP
   
         Level_1_Onhand_Util_API.Increment_Qty_Onhand_(
            total_increment_,
            contract_,
            part_no_,
            png_,
            ms_set_,
            0,
            proj_avail_rec.ms_date,
            demand_tf_date_,
            planning_tf_date_);
   
         proj_avail_ := proj_avail_ - total_increment_;
         
         IF proj_avail_ < 0 THEN  
            IF NOT (Level_1_Message_API.Check_Exist_On_Date (contract_, part_no_, png_, ms_set_, proj_avail_rec.ms_date, 'E515')) THEN
               -- Projected Balance negative.
               Level_1_Message_API.Batch_New__(
                   contract_        => contract_,
                   part_no_         => part_no_,
                   png_             => png_,
                   ms_set_          => ms_set_,
                   ms_date_         => proj_avail_rec.ms_date,
                   order_no_        => NULL,
                   line_no_         => NULL,
                   release_no_      => NULL,
                   line_item_no_    => NULL,
                   order_type_db_   => NULL,
                   activity_seq_    => NULL,
                   msg_code_        => 'E515');
            END IF;
         END IF;
   
         Level_1_Forecast_API.Batch_Modify__ (
            contract_            => contract_,
            part_no_             => part_no_,
            png_                 => png_,
            ms_set_              => ms_set_,
            activity_seq_        => 0,
            ms_date_             => proj_avail_rec.ms_date,
            parent_contract_     => NULL,
            parent_part_         => NULL,
            forecast_lev0_       => NULL,
            forecast_lev1_       => NULL,
            consumed_forecast_   => NULL,
            actual_demand_       => NULL,
            planned_demand_      => NULL,
            supply_              => NULL,
            consumed_supply_     => NULL,
            firm_orders_         => NULL,
            sched_orders_        => NULL,
            rel_ord_rcpt_        => NULL,
            master_sched_rcpt_   => NULL,
            avail_to_prom_       => NULL,
            roll_up_rcpt_        => NULL,
            net_avail_           => NULL,
            proj_avail_          => proj_avail_,
            mtr_demand_qty_      => NULL,
            mtr_supply_qty_      => NULL,
            offset_              => NULL,
            roll_flag_db_        => NULL,
            sysgen_flag_         => NULL,
            master_sched_status_ => NULL,
            method_              => 'UPDATE' );
   
      END LOOP;
   
   EXCEPTION
      WHEN OTHERS THEN
         IF Error_SYS.Is_Foundation_Error(SQLCODE) THEN
            RAISE;
         END IF;
   
         local_contract_ := contract_ || ', Part No ' || part_no_;
   
         Error_Sys.Appl_General (lu_name_, 'CALCPROJAVL: Error :P1 occurred while running LEVEL_1_FORECAST_UTIL_API.Calculate_Proj_Avail_ for Site :P2 MS Set :P3.', SQLERRM, local_contract_, ms_set_);
   END Core;

BEGIN
   General_SYS.Init_Method(LEVEL_1_FORECAST_UTIL_API.lu_name_, 'LEVEL_1_FORECAST_UTIL_API', 'Calculate_Proj_Avail_');
   Core(contract_, part_no_, png_, ms_set_, qty_onhand_, demand_tf_date_, planning_tf_date_, lead_time_code_db_);
END Calculate_Proj_Avail_;

-----------------------------------------------------------------------------
-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------
-----------------------------------------------------------------------------

PROCEDURE Massch_Atp_Check__ (
   result_code_               OUT VARCHAR2,
   available_qty_             OUT NUMBER,
   earliest_available_date_   OUT DATE,
   contract_                  IN VARCHAR2,
   part_no_                   IN VARCHAR2,
   png_                       IN VARCHAR2,
   activity_seq_              IN NUMBER,
   order_line_qty_            IN NUMBER,
   order_line_due_date_       IN DATE,
   promise_method_db_         IN VARCHAR2,
   calendar_id_               IN VARCHAR2,
   ptf_date_                  IN DATE )
IS
   
   PROCEDURE Core (
      result_code_               OUT VARCHAR2,
      available_qty_             OUT NUMBER,
      earliest_available_date_   OUT DATE,
      contract_                  IN VARCHAR2,
      part_no_                   IN VARCHAR2,
      png_                       IN VARCHAR2,
      activity_seq_              IN NUMBER,
      order_line_qty_            IN NUMBER,
      order_line_due_date_       IN DATE,
      promise_method_db_         IN VARCHAR2,
      calendar_id_               IN VARCHAR2,
      ptf_date_                  IN DATE )
   IS
      total_uncon_forec_        NUMBER := 0;
      total_atp_                NUMBER := 0;
      ms_set_                   NUMBER := 1;
      dummy_                    VARCHAR2(2000);
      massch_running            EXCEPTION;
   
      CURSOR get_ucf IS
         SELECT ms_date, NVL(forecast_lev0, 0) + NVL(forecast_lev1, 0) -  NVL(consumed_forecast, 0) uncon_forec
         FROM level_1_forecast_tab
         WHERE contract = contract_
         AND   part_no  = part_no_
         AND   png      = png_
         AND   ms_set   = ms_set_
         AND   activity_seq = activity_seq_
         ORDER BY ms_date;
   
      CURSOR get_atp IS
         SELECT ms_date, NVL(supply, 0) - NVL(consumed_supply, 0) atp
         FROM level_1_forecast_tab
         WHERE contract = contract_
         AND   part_no  = part_no_
         AND   png      = png_
         AND   ms_set   = ms_set_
         AND   activity_seq = activity_seq_
         ORDER BY ms_date;
   
   BEGIN
      -- check if Level 1 is running for this part, and if so, do not
      -- allow booking of orders for this part.
      IF (Level_1_Part_Util_API.Is_Level_One_Running (contract_, part_no_, png_, ms_set_) = 1) THEN
         RAISE massch_running;
      END IF;
   
      available_qty_ := 0;
      IF (promise_method_db_ = 'UCF') THEN
         -- promise method is unconsumed forecast.
         FOR rec_ IN get_ucf LOOP
            total_uncon_forec_ := total_uncon_forec_ + rec_.uncon_forec;
            IF order_line_qty_ <= total_uncon_forec_ AND earliest_available_date_ IS NULL THEN
               -- get the earliest date on which the user requested qty is available.
               earliest_available_date_ := rec_.ms_date;
            END IF;
   
            IF TRUNC(rec_.ms_date) <= TRUNC(order_line_due_date_) THEN
               -- get how much unconsumed forecast qty within order date
               available_qty_ := available_qty_ + rec_.uncon_forec;
            END IF;
   
         END LOOP;
      ELSIF (promise_method_db_ = 'ATP') THEN
         -- promise method is unconsumed supply.
         FOR rec_ IN get_atp LOOP
            total_atp_ := total_atp_ + rec_.atp;
            IF order_line_qty_ <= total_atp_ AND earliest_available_date_ IS NULL THEN
               -- get the earliest date on which the user requested qty is available.
               earliest_available_date_ := rec_.ms_date;
            END IF;
   
            IF TRUNC(rec_.ms_date) <= TRUNC(order_line_due_date_) THEN
               -- get how much available to promise within order date
               available_qty_ := available_qty_ + rec_.atp;
            END IF;
   
         END LOOP;
      END IF;
      
      -- Bug 116050, Combined the phrases in order to resolve the translation issues  
      IF TRUNC(order_line_due_date_) > ptf_date_ THEN
         -- We are outside planning time fence
         -- Logic should not generate hard errors
         IF nvl(earliest_available_date_, Database_SYS.first_calendar_date_) > TRUNC(order_line_due_date_) THEN
            -- Earliest possible date is after order due date
            -- Bug 116050, Changed the message wordings according to the promise method
            IF (promise_method_db_ = 'UCF') THEN
               dummy_   := Language_SYS.Translate_Constant(lu_name_,
                           'ATPCHECKFAIL21A: For Site/Part :P1, the unconsumed forecast will not be available on :P2 is the PTF and order is needed outside the PTF. Desired qty will be available on :P3. ' ||
                           'Consider change forecast/supply qty in MS, or order due/delivery date or qty.',
                           NULL, contract_ ||'/'||part_no_, order_line_due_date_ || '.' || chr(13) || chr(10) || ptf_date_, earliest_available_date_);            
            ELSIF (promise_method_db_ = 'ATP') THEN
               dummy_   := Language_SYS.Translate_Constant(lu_name_,
                           'ATPCHECKFAIL22A: For Site/Part :P1, the unconsumed supply will not be available on :P2 is the PTF and order is needed outside the PTF. Desired qty will be available on :P3. ' ||
                           'Consider change forecast/supply qty in MS, or order due/delivery date or qty.',
                           NULL, contract_ ||'/'||part_no_, order_line_due_date_ || '.' || chr(13) || chr(10) || ptf_date_, earliest_available_date_);
            END IF;               
            -- Just give an info message
            Client_SYS.Add_Info(lu_name_, 'ATPCHECKFAIL5: :P1', dummy_);
            
         ELSIF earliest_available_date_ IS NULL THEN
            -- Bug 116050, Changed the message wordings according to the promise method
            IF (promise_method_db_ = 'UCF') THEN
               dummy_   := Language_SYS.Translate_Constant(lu_name_,
                           'ATPCHECKFAIL21B: For Site/Part :P1, the unconsumed forecast available on :P2 is :P3. Order need date is outside the PTF. It can be made available by ' ||
                           'changing forecast/supply qty in MS, or order due/delivery date or qty.',
                           NULL, contract_ ||'/'||part_no_,order_line_due_date_, available_qty_ ); 
            ELSIF (promise_method_db_ = 'ATP') THEN
               dummy_   := Language_SYS.Translate_Constant(lu_name_,
                           'ATPCHECKFAIL22B: For Site/Part :P1, the unconsumed supply available on :P2 is :P3. Order need date is outside the PTF. It can be made available by ' ||
                           'changing forecast/supply qty in MS, or order due/delivery date or qty.',
                           NULL, contract_ ||'/'||part_no_,order_line_due_date_, available_qty_);
            END IF;
            -- Just give an info message
            Client_SYS.Add_Info(lu_name_, 'ATPCHECKFAIL5: :P1', dummy_);
         END IF;     
         result_code_ := 'SUCCESS';     
      ELSE
         -- We are inside planning time fence
         -- Logic can generate hard errors, the hard error is raised from the ORDER component if result_code != SUCCESS
         IF nvl(earliest_available_date_, Database_SYS.first_calendar_date_) > TRUNC(order_line_due_date_) THEN
            -- earliest possible date is after order due date
              -- Bug 116050, Changed the message wordings according to the promise method
            IF (promise_method_db_ = 'UCF') THEN
               dummy_   := Language_SYS.Translate_Constant(lu_name_,
                           'ATPCHECKFAIL31A: For Site/Part :P1, the unconsumed forecast will not be available on :P2. Desired qty will be available on :P3.',
                           NULL, contract_ ||'/'||part_no_, order_line_due_date_, earliest_available_date_);
            ELSIF (promise_method_db_ = 'ATP') THEN
               dummy_   := Language_SYS.Translate_Constant(lu_name_,
                           'ATPCHECKFAIL32A: For Site/Part :P1, the unconsumed supply will not be available on :P2. Desired qty will be available on :P3.',
                           NULL, contract_ ||'/'||part_no_, order_line_due_date_, earliest_available_date_);            
            END IF;
            result_code_ := dummy_;
            
         ELSIF earliest_available_date_ IS NULL THEN
            earliest_available_date_ := TRUNC(Work_Time_Calendar_API.Get_Next_Work_Day (
                                              calendar_id_,
                                              ptf_date_));
             -- Bug 116050, Changed the message wordings according to the promise method
            IF (promise_method_db_ = 'UCF') THEN
               dummy_   := Language_SYS.Translate_Constant(lu_name_,
                           'ATPCHECKFAIL31B: For Site/Part :P1, the unconsumed forecast available on :P2 is :P3. Planned delivery date or ordered quantity has to be changed.',
                           NULL, contract_ ||'/'||part_no_, order_line_due_date_, available_qty_);
            ELSIF (promise_method_db_ = 'ATP') THEN
               dummy_   := Language_SYS.Translate_Constant(lu_name_,
                           'ATPCHECKFAIL32B: For Site/Part :P1, the unconsumed supply available on :P2 is :P3. Planned delivery date or ordered quantity has to be changed.',
                           NULL, contract_ ||'/'||part_no_,order_line_due_date_, available_qty_);
            END IF;         
            result_code_ := dummy_;         
         ELSE
            result_code_ := 'SUCCESS';
         END IF;
      END IF;
   EXCEPTION
      WHEN massch_running THEN
         Error_Sys.Appl_General(lu_name_, 'LEV1RUNNING: Level 1 is currently running for Site :P1 Part No :P2.', contract_, part_no_);
      WHEN OTHERS THEN
         IF Error_SYS.Is_Foundation_Error(SQLCODE) THEN
            RAISE;
         END IF;
   
         Error_Sys.Appl_General (lu_name_, 'MSATPCHK: Error :P1 occurred while running LEVEL_1_FORECAST_UTIL_API.Massch_Atp_Check for Site :P2 Part No :P3.', SQLERRM, contract_, part_no_);
   END Core;

BEGIN
   General_SYS.Init_Method(LEVEL_1_FORECAST_UTIL_API.lu_name_, 'LEVEL_1_FORECAST_UTIL_API', 'Massch_Atp_Check__');
   Core(result_code_, available_qty_, earliest_available_date_, contract_, part_no_, png_, activity_seq_, order_line_qty_, order_line_due_date_, promise_method_db_, calendar_id_, ptf_date_);
END Massch_Atp_Check__;


PROCEDURE Recalc_Consumed_Fcst__ (
   contract_                 IN VARCHAR2,
   part_no_                  IN VARCHAR2,
   png_                      IN VARCHAR2,
   ms_set_                   IN NUMBER,
   ms_receipt_activity_seq_  IN NUMBER,
   consuming_fcst_online_    IN BOOLEAN,
   source_type_              IN VARCHAR2,
   promise_method_db_        IN VARCHAR2,
   calendar_id_              IN VARCHAR2,
   forecast_consumption_wnd_ IN NUMBER,
   fwd_forecast_consumption_ IN NUMBER )
IS
   
   PROCEDURE Core (
      contract_                 IN VARCHAR2,
      part_no_                  IN VARCHAR2,
      png_                      IN VARCHAR2,
      ms_set_                   IN NUMBER,
      ms_receipt_activity_seq_  IN NUMBER,
      consuming_fcst_online_    IN BOOLEAN,
      source_type_              IN VARCHAR2,
      promise_method_db_        IN VARCHAR2,
      calendar_id_              IN VARCHAR2,
      forecast_consumption_wnd_ IN NUMBER,
      fwd_forecast_consumption_ IN NUMBER )
   IS
      local_contract_      VARCHAR2(200);
      order_line_old_qty_  NUMBER := NULL;
      
      CURSOR actual_demand IS
         SELECT ms_date, NVL(actual_demand, 0) + NVL(planned_demand,0) total_demand, activity_seq
         FROM LEVEL_1_FORECAST_TAB
         WHERE part_no  = part_no_
         AND   contract = contract_
         AND   png      = png_
         AND   ms_set   = ms_set_
         AND   (NVL(actual_demand, 0) + NVL(planned_demand, 0)) > 0
         ORDER BY ms_date;
   
   BEGIN
   
      -- recalc of consumed_forecast starts here. loop is over actual_demand in
      -- ascending chronological order.
      FOR actual_demand_rec IN actual_demand LOOP
         Consume_Forecast (
            contract_,
            part_no_,
            png_,
            ms_set_,
            actual_demand_rec.activity_seq,
            ms_receipt_activity_seq_,
            actual_demand_rec.total_demand,
            order_line_old_qty_,
            actual_demand_rec.ms_date,
            source_type_,
            promise_method_db_,
            forecast_consumption_wnd_,
            fwd_forecast_consumption_,
            calendar_id_,
            consuming_fcst_online_);
      END LOOP;
   
   EXCEPTION
      WHEN OTHERS THEN
         IF Error_SYS.Is_Foundation_Error(SQLCODE) THEN
            RAISE;
         END IF;
   
         local_contract_ := contract_ || '/' || png_ || '/' || part_no_ || '/' || ms_set_;
   
         Error_Sys.Appl_General(lu_name_, 'RECALCCONSUMEDFCST: Error :P1 occurred while running LEVEL_1_FORECAST_UTIL_API.Recalc_Consumed_Fcst__ for Site/PNG/Part No/Ms Set :P2.',
                                SQLERRM, local_contract_);
   END Core;

BEGIN
   General_SYS.Init_Method(LEVEL_1_FORECAST_UTIL_API.lu_name_, 'LEVEL_1_FORECAST_UTIL_API', 'Recalc_Consumed_Fcst__');
   Core(contract_, part_no_, png_, ms_set_, ms_receipt_activity_seq_, consuming_fcst_online_, source_type_, promise_method_db_, calendar_id_, forecast_consumption_wnd_, fwd_forecast_consumption_);
END Recalc_Consumed_Fcst__;


PROCEDURE Recalc_Consumed_Supply__ (
   contract_                IN VARCHAR2,
   part_no_                 IN VARCHAR2,
   png_                     IN VARCHAR2,
   ms_set_                  IN NUMBER,
   consuming_fcst_online_   IN BOOLEAN,
   source_type_             IN VARCHAR2,
   promise_method_db_       IN VARCHAR2,
   calendar_id_             IN VARCHAR2,
   order_line_cancellation_ IN BOOLEAN )
IS
   
   PROCEDURE Core (
      contract_                IN VARCHAR2,
      part_no_                 IN VARCHAR2,
      png_                     IN VARCHAR2,
      ms_set_                  IN NUMBER,
      consuming_fcst_online_   IN BOOLEAN,
      source_type_             IN VARCHAR2,
      promise_method_db_       IN VARCHAR2,
      calendar_id_             IN VARCHAR2,
      order_line_cancellation_ IN BOOLEAN )
   IS
      error_info_         VARCHAR2(200);
      order_line_old_qty_ NUMBER := NULL;
   
      CURSOR actual_demand IS
         SELECT ms_date, activity_seq,
                NVL(actual_demand, 0)  actual_demand,
                NVL(planned_demand, 0) planned_demand
                -- NVL(mtr_demand_qty, 0) mtr_demand_qty
         FROM LEVEL_1_FORECAST_TAB
         WHERE contract = contract_
         AND   part_no  = part_no_
         AND   png      = png_
         AND   ms_set   = ms_set_
         AND   ( NVL(actual_demand, 0)  > 0 OR
                 NVL(planned_demand, 0) > 0 )
         -- AND   ( NVL(actual_demand, 0)  > 0 OR
         --        NVL(planned_demand, 0) > 0 OR
         --        NVL(mtr_demand_qty, 0) > 0)
         ORDER BY ms_date;
   
   BEGIN
   
      -- recalc of consumed supply starts here. loop is over actual_demand in
      -- ascending chronological order.
      FOR actual_demand_rec IN actual_demand LOOP
         Consume_Supply (
            contract_,
            part_no_,
            png_,
            ms_set_,
            actual_demand_rec.activity_seq,
            actual_demand_rec.actual_demand + actual_demand_rec.planned_demand, -- + actual_demand_rec.mtr_demand_qty,
            order_line_old_qty_,
            actual_demand_rec.ms_date,
            promise_method_db_,
            calendar_id_,
            consuming_fcst_online_,
            source_type_,
            order_line_cancellation_);
      END LOOP;
   
   EXCEPTION
      WHEN OTHERS THEN
         IF Error_SYS.Is_Foundation_Error(SQLCODE) THEN
            RAISE;
         END IF;
   
         error_info_ := contract_ || '/' || png_ || '/' || part_no_ || '/' || ms_set_;
         Error_Sys.Appl_General (lu_name_, 'CONSUP: Error :P1 occurred while running LEVEL_1_FORECAST_UTIL_API.Consume_Supply for Site/PNG/Part No/Ms Set :P2.',
            SQLERRM,
            error_info_);
   END Core;

BEGIN
   General_SYS.Init_Method(LEVEL_1_FORECAST_UTIL_API.lu_name_, 'LEVEL_1_FORECAST_UTIL_API', 'Recalc_Consumed_Supply__');
   Core(contract_, part_no_, png_, ms_set_, consuming_fcst_online_, source_type_, promise_method_db_, calendar_id_, order_line_cancellation_);
END Recalc_Consumed_Supply__;


PROCEDURE Rollout_Unconsumed_Fcst__ (
   contract_                IN VARCHAR2,
   part_no_                 IN VARCHAR2,
   png_                     IN VARCHAR2,
   ms_set_                  IN NUMBER,
   ms_receipt_activity_seq_ IN NUMBER,
   dtf_date_                IN DATE,
   calendar_id_             IN VARCHAR2,
   max_unconsumed_fcst_     IN NUMBER,
   roll_by_percentage_      IN NUMBER,
   roll_window_             IN NUMBER )
IS
   
   PROCEDURE Core (
      contract_                IN VARCHAR2,
      part_no_                 IN VARCHAR2,
      png_                     IN VARCHAR2,
      ms_set_                  IN NUMBER,
      ms_receipt_activity_seq_ IN NUMBER,
      dtf_date_                IN DATE,
      calendar_id_             IN VARCHAR2,
      max_unconsumed_fcst_     IN NUMBER,
      roll_by_percentage_      IN NUMBER,
      roll_window_             IN NUMBER )
   IS
      error_info_                VARCHAR2(200);
      total_unconsumed_fcst_     NUMBER;
      date_outside_dtf_          DATE;
      rounded_unconsumed_fcst_   NUMBER;
      total_unconsumed_          NUMBER;
      rollout_arr_               Rollout_Unconsumed_Fcst_API.Rollout_Collection;
      total_                     NUMBER;
      
      -- get unconsumed forecast records inside DTF.
      CURSOR get_unconsumed_fcst IS
         SELECT ms_date, (NVL(forecast_lev0, 0) + NVL(forecast_lev1, 0) - NVL(consumed_forecast, 0)) unconsumed_forecast
         FROM LEVEL_1_FORECAST_TAB
         WHERE contract   = contract_
         AND part_no      = part_no_
         AND png          = png_
         AND ms_set       = ms_set_
         AND activity_seq = ms_receipt_activity_seq_
         AND ms_date     <= dtf_date_
         AND (NVL(forecast_lev0, 0) + NVL(forecast_lev1, 0) - NVL(consumed_forecast, 0)) > 0;
   
   BEGIN
   
      -- get total unconsumed forecast inside DTF.
      SELECT SUM(NVL(forecast_lev0, 0) + NVL(forecast_lev1, 0) - NVL(consumed_forecast, 0))
         INTO total_unconsumed_fcst_
      FROM LEVEL_1_FORECAST_TAB
      WHERE contract   = contract_
      AND part_no      = part_no_
      AND png          = png_
      AND ms_set       = ms_set_
      AND activity_seq = ms_receipt_activity_seq_
      AND ms_date     <= dtf_date_;
   
      -- check to see if a forecast rec exists for the first workday outside
      -- the DTF. this is the rec in which rolled out unconsumed forecast
      -- will be accumulated. if not, insert one, else existing rec will be
      -- updated with rolled out unconsumed forecasts.
      IF (total_unconsumed_fcst_ > 0) THEN
         
         date_outside_dtf_ := dtf_date_ + 1;
         IF roll_by_percentage_ < 100 THEN
            total_ := total_unconsumed_fcst_;
            total_unconsumed_fcst_ := 0;
            FOR fcst_rec_ IN get_unconsumed_fcst LOOP
               total_unconsumed_ := 0;
               IF (Rollout_Unconsumed_Fcst_API.Check_Roll_Out_Date(contract_, part_no_, png_, ms_set_, fcst_rec_.ms_date)) THEN                               
                  rollout_arr_ := Rollout_Unconsumed_Fcst_API.Get_Orig_Forecast_Date_Qty(contract_, part_no_, png_, ms_set_, fcst_rec_.ms_date);
                  FOR row_index IN rollout_arr_.FIRST .. rollout_arr_.LAST LOOP
                     total_unconsumed_ := total_unconsumed_ + rollout_arr_(row_index).unconsumed_forecast;
                     Rollout_Unconsumed_Fcst_API.Modify(contract_, part_no_, png_, ms_set_, rollout_arr_(row_index).orig_ms_date, date_outside_dtf_, NULL);
                     IF ((roll_window_ > 0) AND ((date_outside_dtf_ - rollout_arr_(row_index).orig_ms_date) > roll_window_ )) THEN
                        Rollout_Unconsumed_Fcst_API.Remove(contract_, part_no_, png_, ms_set_, rollout_arr_(row_index).orig_ms_date);
                        IF (fcst_rec_.unconsumed_forecast >= rollout_arr_(row_index).unconsumed_forecast) THEN
                           fcst_rec_.unconsumed_forecast := fcst_rec_.unconsumed_forecast - rollout_arr_(row_index).unconsumed_forecast;
                           total_unconsumed_ := total_unconsumed_ - rollout_arr_(row_index).unconsumed_forecast;
                        ELSE
                           fcst_rec_.unconsumed_forecast := 0;
                           total_unconsumed_ := 0;
                        END IF;
                     END IF;
                  END LOOP;
                  IF (fcst_rec_.unconsumed_forecast > total_unconsumed_) THEN
                     IF NOT((roll_window_ > 0) AND ((date_outside_dtf_ - fcst_rec_.ms_date) > roll_window_ )) THEN                                       
                        IF (total_ > total_unconsumed_) THEN
                           rounded_unconsumed_fcst_ := ((fcst_rec_.unconsumed_forecast - total_unconsumed_) * roll_by_percentage_)/100;
                           rounded_unconsumed_fcst_ := Inventory_Part_API.Get_Calc_Rounded_Qty(contract_, part_no_, rounded_unconsumed_fcst_);
                           total_unconsumed_fcst_   := total_unconsumed_fcst_ + total_unconsumed_ + rounded_unconsumed_fcst_;
                           Rollout_Unconsumed_Fcst_API.New(contract_, part_no_, png_, ms_set_, fcst_rec_.ms_date, date_outside_dtf_, rounded_unconsumed_fcst_);
                        ELSE
                           total_unconsumed_fcst_   := total_unconsumed_fcst_ + fcst_rec_.unconsumed_forecast;
                        END IF;
                     END IF;
                  ELSE  
                     total_unconsumed_fcst_   := total_unconsumed_fcst_ + fcst_rec_.unconsumed_forecast;
                  END IF;
               ELSE               
                  IF NOT((roll_window_ > 0) AND ((date_outside_dtf_ - fcst_rec_.ms_date) > roll_window_ )) THEN 
                     total_unconsumed_ := NVL(Rollout_Unconsumed_Fcst_API.Get_Total_Qty(contract_, part_no_, png_, ms_set_,dtf_date_),0);
                     IF (Rollout_Unconsumed_Fcst_API.Check_Orig_Fcst_Date(contract_, part_no_, png_, ms_set_,fcst_rec_.ms_date)) THEN  
                        total_unconsumed_fcst_   := total_unconsumed_fcst_ + fcst_rec_.unconsumed_forecast;
                     ELSE                                                       
                        IF (total_ > total_unconsumed_) THEN
                           rounded_unconsumed_fcst_ := (fcst_rec_.unconsumed_forecast * roll_by_percentage_)/100;
                           rounded_unconsumed_fcst_ := Inventory_Part_API.Get_Calc_Rounded_Qty(contract_, part_no_, rounded_unconsumed_fcst_);
                           total_unconsumed_fcst_   := total_unconsumed_fcst_ + rounded_unconsumed_fcst_;
                           Rollout_Unconsumed_Fcst_API.New(contract_, part_no_, png_, ms_set_, fcst_rec_.ms_date, date_outside_dtf_, rounded_unconsumed_fcst_);
                        ELSE
                           total_unconsumed_fcst_   := total_unconsumed_fcst_ + fcst_rec_.unconsumed_forecast;
                        END IF;
                     END IF;
                  END IF;
               END IF;
            END LOOP;
         END IF; 
         IF (roll_window_ > 0 AND roll_by_percentage_ = 100) THEN
            FOR fcst_rec_ IN get_unconsumed_fcst LOOP
               total_unconsumed_ := 0;
               IF (Rollout_Unconsumed_Fcst_API.Check_Roll_Out_Date(contract_, part_no_, png_, ms_set_, fcst_rec_.ms_date)) THEN            
                  rollout_arr_ := Rollout_Unconsumed_Fcst_API.Get_Orig_Forecast_Date_Qty(contract_, part_no_, png_, ms_set_, fcst_rec_.ms_date);           
                  FOR row_index IN rollout_arr_.FIRST .. rollout_arr_.LAST LOOP
                     total_unconsumed_ := total_unconsumed_ + rollout_arr_(row_index).unconsumed_forecast;
                     Rollout_Unconsumed_Fcst_API.Modify(contract_, part_no_, png_, ms_set_, rollout_arr_(row_index).orig_ms_date, date_outside_dtf_, NULL);
                     IF ((date_outside_dtf_ - rollout_arr_(row_index).orig_ms_date) > roll_window_ ) THEN
                        Rollout_Unconsumed_Fcst_API.Remove(contract_, part_no_, png_, ms_set_, rollout_arr_(row_index).orig_ms_date);
                        IF (total_unconsumed_fcst_ >= rollout_arr_(row_index).unconsumed_forecast) THEN
                           total_unconsumed_fcst_ := total_unconsumed_fcst_ - rollout_arr_(row_index).unconsumed_forecast;
                        ELSE
                           total_unconsumed_fcst_ := 0;
                           EXIT;
                        END IF;
                     END IF;                 
                  END LOOP;
                  IF (fcst_rec_.unconsumed_forecast > total_unconsumed_) THEN
                     Rollout_Unconsumed_Fcst_API.New(contract_, part_no_, png_, ms_set_, fcst_rec_.ms_date, date_outside_dtf_, (fcst_rec_.unconsumed_forecast - total_unconsumed_));
                  END IF;
               ELSE
                  IF NOT(Rollout_Unconsumed_Fcst_API.Check_Roll_Out_Date(contract_, part_no_, png_, ms_set_, date_outside_dtf_)) THEN 
                     total_unconsumed_ := NVL(Rollout_Unconsumed_Fcst_API.Get_Total_Qty(contract_, part_no_, png_, ms_set_,dtf_date_),0);                  
                     IF ((date_outside_dtf_ - fcst_rec_.ms_date) < roll_window_ AND total_unconsumed_fcst_ > total_unconsumed_) THEN
                        IF (Rollout_Unconsumed_Fcst_API.Check_Orig_Fcst_Date(contract_, part_no_, png_, ms_set_,fcst_rec_.ms_date)) THEN 
                           Rollout_Unconsumed_Fcst_API.New(contract_, part_no_, png_, ms_set_, fcst_rec_.ms_date, date_outside_dtf_, fcst_rec_.unconsumed_forecast);
                        END IF;
                     ELSE
                        IF (total_unconsumed_fcst_ >= fcst_rec_.unconsumed_forecast) THEN
                           total_unconsumed_fcst_ := total_unconsumed_fcst_ - fcst_rec_.unconsumed_forecast;
                        ELSE
                           total_unconsumed_fcst_ := 0;
                           EXIT;
                        END IF;
                     END IF;
                  END IF;
               END IF;
            END LOOP;
         END IF;
         
         IF max_unconsumed_fcst_ > 0 THEN
            IF max_unconsumed_fcst_ < total_unconsumed_fcst_ THEN
               total_unconsumed_fcst_ := max_unconsumed_fcst_;
            END IF;
         END IF;
         
         IF total_unconsumed_fcst_ > 0 THEN
            IF NOT Level_1_Forecast_API.Check_Exist(contract_, part_no_, png_, ms_set_, 0, date_outside_dtf_) THEN
   
               Level_1_Forecast_API.Batch_New__(
                  contract_            => contract_,
                  part_no_             => part_no_,
                  png_                 => png_,
                  ms_set_              => ms_set_,
                  activity_seq_        => ms_receipt_activity_seq_,
                  ms_date_             => date_outside_dtf_,
                  parent_contract_     => NULL,
                  parent_part_         => NULL,           
                  forecast_lev0_       => 0,
                  forecast_lev1_       => total_unconsumed_fcst_,
                  consumed_forecast_   => 0,
                  actual_demand_       => 0,
                  planned_demand_      => 0,
                  supply_              => 0,
                  consumed_supply_     => 0,
                  firm_orders_         => 0,
                  sched_orders_        => 0,
                  rel_ord_rcpt_        => 0,
                  master_sched_rcpt_   => 0,
                  avail_to_prom_       => 0,
                  roll_up_rcpt_        => NULL,
                  net_avail_           => 0,
                  proj_avail_          => 0,
                  mtr_demand_qty_      => 0,
                  mtr_supply_qty_      => 0,
                  offset_              => NULL,
                  sysgen_flag_         => Sysgen_API.Decode(sysgen_yes_),
                  master_sched_status_ => Master_Sched_Status_API.Decode(Master_Sched_Status_API.DB_PROPOSED_MS_RECEIPT));
   
            ELSE
   
               Level_1_Forecast_API.Batch_Modify__ (
                  contract_            => contract_,
                  part_no_             => part_no_,
                  png_                 => png_,
                  ms_set_              => ms_set_,
                  activity_seq_        => ms_receipt_activity_seq_,
                  ms_date_             => date_outside_dtf_,
                  parent_contract_     => NULL,
                  parent_part_         => NULL,            
                  forecast_lev0_       => NULL,
                  forecast_lev1_       => total_unconsumed_fcst_,
                  consumed_forecast_   => NULL,
                  actual_demand_       => NULL,
                  planned_demand_      => NULL,
                  supply_              => NULL,
                  consumed_supply_     => NULL,
                  firm_orders_         => NULL,
                  sched_orders_        => NULL,
                  rel_ord_rcpt_        => NULL,
                  master_sched_rcpt_   => NULL,
                  avail_to_prom_       => NULL,
                  roll_up_rcpt_        => NULL,
                  net_avail_           => NULL,
                  proj_avail_          => NULL,
                  mtr_demand_qty_      => NULL,
                  mtr_supply_qty_      => NULL,
                  offset_              => NULL,
                  roll_flag_db_        => NULL,
                  sysgen_flag_         => NULL,
                  master_sched_status_ => NULL,
                  method_              => 'ADD' );
   
            END IF;
         END IF;
      END IF;
   
   EXCEPTION
      WHEN OTHERS THEN
         IF Error_SYS.Is_Foundation_Error(SQLCODE) THEN
            RAISE;
         END IF;
   
         error_info_ := contract_ || '/' || png_ || '/' || part_no_ || '/' || ms_set_;
   
         Error_Sys.Appl_General (lu_name_, 'ROLLOUTUNCONFCST: Error :P1 occurred while running LEVEL_1_FORECAST_UTIL_API.Rollout_Unconsumed_Fcst__ for Site/PNG/Part No/Ms Set :P2.',
            SQLERRM,
            error_info_);
   END Core;

BEGIN
   General_SYS.Init_Method(LEVEL_1_FORECAST_UTIL_API.lu_name_, 'LEVEL_1_FORECAST_UTIL_API', 'Rollout_Unconsumed_Fcst__');
   Core(contract_, part_no_, png_, ms_set_, ms_receipt_activity_seq_, dtf_date_, calendar_id_, max_unconsumed_fcst_, roll_by_percentage_, roll_window_);
END Rollout_Unconsumed_Fcst__;


PROCEDURE Recalc_Level1_Supply__ (
   contract_      IN VARCHAR2,
   part_no_       IN VARCHAR2,
   png_           IN VARCHAR2,
   ms_set_        IN NUMBER,
   run_date_      IN DATE,
   dtf_date_      IN DATE,
   ptf_date_      IN DATE,
   qty_onhand_    IN NUMBER)
IS
   
   PROCEDURE Core (
      contract_      IN VARCHAR2,
      part_no_       IN VARCHAR2,
      png_           IN VARCHAR2,
      ms_set_        IN NUMBER,
      run_date_      IN DATE,
      dtf_date_      IN DATE,
      ptf_date_      IN DATE,
      qty_onhand_    IN NUMBER)
   IS
      error_info_       VARCHAR2(200);
      supply_           NUMBER  := 0;
      onhand_added_     BOOLEAN := FALSE;   
   
      CURSOR level_1_fcst IS
         SELECT ms_date
         FROM LEVEL_1_FORECAST_TAB
         WHERE contract = contract_
         AND   part_no  = part_no_
         AND   png      = png_
         AND   ms_set   = ms_set_
         AND   (NVL(master_sched_rcpt, 0) > 0
             OR NVL(rel_ord_rcpt, 0)      > 0
             OR NVL(firm_orders,  0)      > 0
             OR NVL(sched_orders, 0)      > 0)
         UNION
         SELECT run_date_ ms_date
         FROM dual
         WHERE qty_onhand_ > 0
         UNION
         SELECT MIN(ms_date) ms_date
         FROM LEVEL_1_FORECAST_TAB
         WHERE contract = contract_
         AND   part_no  = part_no_
         AND   ms_set   = ms_set_
         AND   png      = png_
         AND   ms_date < run_date_      
         ORDER BY 1;
   BEGIN
      
      FOR cursor_rec IN level_1_fcst LOOP
         IF (cursor_rec.ms_date IS NOT NULL) THEN   
            IF (cursor_rec.ms_date > dtf_date_) THEN
               SELECT NVL(rel_ord_rcpt, 0) + NVL(firm_orders, 0) + NVL(sched_orders, 0) +
                      GREATEST(NVL(master_sched_rcpt, 0) -
                                Inventory_Part_Planning_API.Get_Scrap_Removed_Qty(contract,
                                                                                  part_no,
                                    Supply_Order_Detail_API.Get_Supply_Converted_To_Order(contract,
                                                                                          part_no,
                                                                                          png,
                                                                                          ms_set,
                                                                                          ms_date)), 0)
                  INTO supply_
               FROM LEVEL_1_FORECAST_TAB
               WHERE contract = contract_
               AND   part_no  = part_no_
               AND   png      = png_
               AND   ms_set   = ms_set_
               AND   ms_date  = cursor_rec.ms_date;
            ELSE
               BEGIN 
                  SELECT NVL(rel_ord_rcpt, 0) + NVL(firm_orders, 0) + NVL(sched_orders, 0)
                     INTO supply_
                  FROM LEVEL_1_FORECAST_TAB
                  WHERE contract = contract_
                  AND   part_no  = part_no_
                  AND   png      = png_
                  AND   ms_set   = ms_set_
                  AND   ms_date  = cursor_rec.ms_date;
               EXCEPTION
                  WHEN no_data_found THEN
                     NULL;
               END;
            END IF;
   
            IF (cursor_rec.ms_date <= run_date_ AND NOT onhand_added_) THEN
               supply_ := NVL(supply_, 0) + qty_onhand_;
               onhand_added_ := TRUE;
            END IF;
   
            Level_1_Forecast_API.Batch_Modify__ (
               contract_            => contract_,
               part_no_             => part_no_,
               png_                 => png_,
               ms_set_              => ms_set_,
               activity_seq_        => 0,
               ms_date_             => cursor_rec.ms_date,
               parent_contract_     => NULL,
               parent_part_         => NULL,
               forecast_lev0_       => NULL,
               forecast_lev1_       => NULL,
               consumed_forecast_   => NULL,
               actual_demand_       => NULL,
               planned_demand_      => NULL,
               supply_              => NVL(supply_, 0),
               consumed_supply_     => NULL,
               firm_orders_         => NULL,
               sched_orders_        => NULL,
               rel_ord_rcpt_        => NULL,
               master_sched_rcpt_   => NULL,
               avail_to_prom_       => NULL,
               roll_up_rcpt_        => NULL,
               net_avail_           => NULL,
               proj_avail_          => NULL,
               mtr_demand_qty_      => NULL,
               mtr_supply_qty_      => NULL,
               offset_              => NULL,
               roll_flag_db_        => NULL,
               sysgen_flag_         => NULL,
               master_sched_status_ => NULL,
               method_              => 'UPDATE' );
   
            supply_ := 0;
         END IF; 
      END LOOP;
   
   EXCEPTION
      WHEN OTHERS THEN
         IF Error_SYS.Is_Foundation_Error(SQLCODE) THEN
            RAISE;
         END IF;
   
         error_info_ := contract_ || '/' || png_ || '/' || part_no_ || '/' || ms_set_;
   
         Error_Sys.Appl_General(lu_name_, 'RECALCLEV1SUP: Error :P1 occurred while running LEVEL_1_FORECAST_UTIL_API.Recalc_Level1_Supply__ for Site/PNG/Part No/Ms Set :P2.',
            SQLERRM,
            error_info_);
   END Core;

BEGIN
   General_SYS.Init_Method(LEVEL_1_FORECAST_UTIL_API.lu_name_, 'LEVEL_1_FORECAST_UTIL_API', 'Recalc_Level1_Supply__');
   Core(contract_, part_no_, png_, ms_set_, run_date_, dtf_date_, ptf_date_, qty_onhand_);
END Recalc_Level1_Supply__;


PROCEDURE Remove_Shop_Proposal__ (
   contract_             IN VARCHAR2,
   part_no_              IN VARCHAR2,
   png_                  IN VARCHAR2,
   period_1_             IN DATE,
   period_2_             IN DATE,
   pmps_run_seq_         IN NUMBER,
   activity_seq_         IN NUMBER )
IS
   
   PROCEDURE Core (
      contract_             IN VARCHAR2,
      part_no_              IN VARCHAR2,
      png_                  IN VARCHAR2,
      period_1_             IN DATE,
      period_2_             IN DATE,
      pmps_run_seq_         IN NUMBER,
      activity_seq_         IN NUMBER )
   IS
      parent_date_       DATE;
      parent_line_no_    NUMBER;
      massch_shop_prop_  VARCHAR2(200) := Shop_Proposal_Type_API.Get_Client_Value(0);
   
      CURSOR get_sub_orders IS
         SELECT ms_date, line_no, sysgen_flag
         FROM ms_receipt_tab
         WHERE contract = contract_
         AND   part_no  = part_no_
         AND   png      = png_
         AND   ms_set   = 1
         AND   activity_seq = activity_seq_
         AND   ms_date  >= period_1_
         AND   NVL(master_sched_rcpt, 0) > 0;
   
      CURSOR get_sup_order_dtls IS
         SELECT supply_order_no,
                supply_order_seq
         FROM supply_order_detail_tab
         WHERE contract          = contract_
         AND   part_no           = part_no_
         AND   png               = png_
         AND   ms_set            = 1
         AND   activity_seq      = activity_seq_
         AND   ms_date           = parent_date_
         AND   line_no           = parent_line_no_
         AND   supply_order_type = 'SO'
         AND   order_created     = 'FALSE';
   
   BEGIN
   
      FOR sub_order_rec_ IN get_sub_orders LOOP
         parent_date_ := sub_order_rec_.ms_date;
         parent_line_no_ := sub_order_rec_.line_no;
   
         FOR sup_dtls_rec_ IN get_sup_order_dtls LOOP
            IF ((sub_order_rec_.ms_date >= period_1_ AND sub_order_rec_.ms_date <= period_2_) OR
                (sub_order_rec_.ms_date > period_2_ AND sub_order_rec_.sysgen_flag = 'N')) THEN
               IF (Shop_Order_Prop_API.Is_Shop_Order_Created (sup_dtls_rec_.supply_order_no) = 1) THEN
                  Supply_Order_Detail_API.Batch_Modify__ (
                     contract_           => contract_,
                     part_no_            => part_no_,
                     png_                => png_,
                     ms_set_             => 1,
                     activity_seq_       => activity_seq_,
                     ms_date_            => sub_order_rec_.ms_date,
                     line_no_            => sub_order_rec_.line_no,
                     supply_order_type_  => 'SO',
                     supply_order_seq_   => sup_dtls_rec_.supply_order_seq,
                     supply_order_no_    => NULL,
                     supply_release_no_  => NULL,
                     supply_sequence_no_ => NULL,
                     order_qty_          => NULL,
                     order_created_      => 'TRUE', -- The SO Req has been converted to a SO
                     method_             => 'MAKE NULL' );
               ELSE -- Remove the supply connection
                  Supply_Order_Detail_API.Batch_Remove__ (
                     contract_          => contract_,
                     part_no_           => part_no_,
                     png_               => png_,
                     ms_set_            => 1,
                     ms_date_           => sub_order_rec_.ms_date,
                     activity_seq_      => activity_seq_,
                     line_no_           => sub_order_rec_.line_no,
                     supply_order_type_ => 'SO',
                     supply_order_seq_  => sup_dtls_rec_.supply_order_seq );
               END IF;
            END IF;
         END LOOP;
      END LOOP;
   
      IF png_ = '*' THEN
         Shop_Order_Prop_API.Remove_Proposal (part_no_, contract_, NULL, massch_shop_prop_);
      ELSE
         Shop_Order_Prop_API.Remove_Pmrp_Proposal(
                                 contract_            => contract_,
                                 part_no_             => part_no_,
                                 exclude_ppsa_in_png_ => NULL,
                                 project_id_          => NULL,
                                 png_                 => png_,
                                 pmrp_run_seq_        => pmps_run_seq_,
                                 shop_proposal_type_  => 'PMPS');
      END IF;
   
   EXCEPTION
      WHEN OTHERS THEN
         IF Error_SYS.Is_Foundation_Error(SQLCODE) THEN
            RAISE;
         END IF;
   
         Error_Sys.Appl_General (lu_name_, 'REMOVESHOPPROP: Error :P1 occurred while running LEVEL_1_FORECAST_UTIL_API.Remove_Shop_Proposal__ for Site :P2 PNG :P3.',
                                 SQLERRM, contract_||' / '||part_no_, png_);
   END Core;

BEGIN
   General_SYS.Init_Method(LEVEL_1_FORECAST_UTIL_API.lu_name_, 'LEVEL_1_FORECAST_UTIL_API', 'Remove_Shop_Proposal__');
   Core(contract_, part_no_, png_, period_1_, period_2_, pmps_run_seq_, activity_seq_);
END Remove_Shop_Proposal__;


PROCEDURE Generate_Shop_Proposal__ (
   contract_                IN VARCHAR2,
   part_no_                 IN VARCHAR2,
   png_                     IN VARCHAR2,
   ms_receipt_activity_seq_ IN NUMBER,
   split_manuf_acquired_    IN VARCHAR2,
   period_1_                IN DATE,
   period_2_                IN DATE,
   calendar_id_             IN VARCHAR2,
   start_crp_calc_          IN BOOLEAN,
   do_supply_arr_           IN Supply_Collection,
   inside_ptf_              IN BOOLEAN DEFAULT TRUE )
IS
   
   PROCEDURE Core (
      contract_                IN VARCHAR2,
      part_no_                 IN VARCHAR2,
      png_                     IN VARCHAR2,
      ms_receipt_activity_seq_ IN NUMBER,
      split_manuf_acquired_    IN VARCHAR2,
      period_1_                IN DATE,
      period_2_                IN DATE,
      calendar_id_             IN VARCHAR2,
      start_crp_calc_          IN BOOLEAN,
      do_supply_arr_           IN Supply_Collection,
      inside_ptf_              IN BOOLEAN DEFAULT TRUE )
   IS
      proposal_no_            VARCHAR2(20);
      req_qty_                NUMBER;
      eng_chg_level_          VARCHAR2(10);
      percent_mfd_            NUMBER;
      prop_start_date_        DATE;
      prop_start_counter_     NUMBER;
      ms_shop_prop_type_      VARCHAR2(200);
      project_id_             VARCHAR2(10);
      activity_seq_           NUMBER;
      bom_type_               VARCHAR2(200) := Shop_Ord_Code_API.Get_Client_Value(0);
      counter_                NUMBER;
      routing_revision_       VARCHAR2(2);
      routing_alternative_no_ VARCHAR2(20);
      rout_alternate_rec_     Routing_Alternate_API.Public_Rec;
      crp_source_db_          VARCHAR2(4);
      
      CURSOR get_sub_orders IS
         SELECT ms_date, line_no, master_sched_rcpt
         FROM ms_receipt_tab
         WHERE contract     = contract_
         AND   part_no      = part_no_
         AND   png          = png_
         AND   ms_set       = 1
         AND   activity_seq = ms_receipt_activity_seq_
         AND   ms_date  BETWEEN period_1_ AND period_2_
         AND   NVL(master_sched_rcpt, 0) > 0
         ORDER BY ms_date;
   
   BEGIN
      -- Trace_SYS.Message('Generate_Shop_Proposal__ with png/activity_seq/period_1_/period_1_:'||png_||'/'||ms_receipt_activity_seq_||'/'||period_1_||'/'||period_2_);
      FOR sub_order_rec_ IN get_sub_orders LOOP
               
         req_qty_ := sub_order_rec_.master_sched_rcpt;
         
         IF (split_manuf_acquired_ = 'SPLIT') THEN
            percent_mfd_ := NVL(Inventory_Part_Planning_API.Get_Percent_Manufactured(contract_, part_no_), 0);
            req_qty_ := req_qty_ * (percent_mfd_/100);
         END IF;
         -- If there are any reqs that have been converted to orders subtract that firm/released supply below.
         req_qty_ := req_qty_ - Supply_Order_Detail_API.Get_Supply_Converted_To_Order (
                                                               contract_,
                                                               part_no_,
                                                               png_,
                                                               1,
                                                               sub_order_rec_.ms_date,
                                                               sub_order_rec_.line_no);
         IF png_ = '*' THEN 
            -- The distribution orders are treated as firm supply immediately when they are created so we need add this
            -- qty back to req_qty_. Coz we are reducing the make qty both when applying the make/buy split percentage and with DOs just created
            -- within Generate_Do__.
            IF do_supply_arr_.COUNT > 0 THEN
               FOR row_index IN do_supply_arr_.FIRST .. do_supply_arr_.LAST LOOP
                  IF do_supply_arr_(row_index).ms_date = sub_order_rec_.ms_date AND
                     do_supply_arr_(row_index).line_no = sub_order_rec_.line_no THEN
                     req_qty_ := req_qty_ + do_supply_arr_(row_index).supply_qty;
                     EXIT;
                  END IF;
               END LOOP;
            END IF;
         END IF;
   
         IF req_qty_ > 0 THEN
            counter_ := Work_Time_Calendar_API.Get_Work_Day_Counter (calendar_id_, sub_order_rec_.ms_date );
            req_qty_ :=Inventory_Part_API.Get_Calc_Rounded_Qty(contract_, part_no_, req_qty_);
            -- Get the relavant routing rev/alt.
            Routing_List_API.Get_Build_Plan_Alternative(routing_revision_, routing_alternative_no_, contract_, part_no_,
                                                        bom_type_, sub_order_rec_.ms_date, req_qty_);
      
            rout_alternate_rec_ := Routing_Alternate_API.Get(contract_, part_no_, routing_revision_, 'M', routing_alternative_no_);
            
            Routing_Head_Leadtime_API.Determine_Mrp_Start_Date (
                  start_date_                => prop_start_date_,
                  start_counter_             => prop_start_counter_,
                  due_counter_               => counter_,
                  leadtime_                  => Inventory_Part_API.Get_Manuf_Leadtime(contract_, part_no_),
                  fixed_lead_time_by_day_    => rout_alternate_rec_.fixed_leadtime_day,
                  variable_lead_time_by_day_ => rout_alternate_rec_.variable_leadtime_day,
                  lead_time_code_db_         => 'M',
                  qty_demand_                => req_qty_,
                  contract_                  => contract_,
                  manuf_calendar_id_         => calendar_id_,
                  dist_calendar_id_          => NULL);
   
            -- Do not generate Shop Proposal if product structure is not in state
            -- plannable or buildable.
            eng_chg_level_ := Part_Revision_API.Get_Revision_By_Date (contract_, part_no_, TRUNC(prop_start_date_));      
   
            IF Manuf_Struct_Alternate_API.Is_Structure_Plannable (
                  contract_       => contract_,
                  part_no_        => part_no_,
                  eng_chg_level_  => eng_chg_level_,
                  bom_type_       => bom_type_,
                  alternative_no_ => alternative_no_) THEN
                  
               IF png_ = '*' THEN
                  ms_shop_prop_type_ := Shop_Proposal_Type_API.Get_Client_Value(0);
                  project_id_ := NULL;
                  activity_seq_ := NULL;
               ELSE
                  ms_shop_prop_type_ := Shop_Proposal_Type_API.Get_Client_Value(7);
                  project_id_ := png_;
                  activity_seq_ := ms_receipt_activity_seq_;
               END IF;
   
               Shop_Order_Prop_API.Generate_Proposal(   
                   proposal_no_            => proposal_no_,
                   mrp_start_date_         => prop_start_date_,
                   part_no_                => part_no_,
                   contract_               => contract_,
                   counter_                => counter_,
                   revised_due_date_       => sub_order_rec_.ms_date,
                   plan_order_rec_         => req_qty_,
                   type_                   => ms_shop_prop_type_,
                   eng_chg_level_          => eng_chg_level_,
                   alternative_no_         => alternative_no_,
                   routing_revision_       => routing_revision_,
                   routing_alternative_no_ => routing_alternative_no_,
                   activity_seq_           => activity_seq_,
                   project_id_             => project_id_ );
               
               IF routing_revision_ IS NULL THEN
                 Trace_SYS.Message('*** Routing Rev prob ***'); 
               END IF;
               
               IF start_crp_calc_ THEN
                 Trace_SYS.Message('*** Start CRP ***');
               ELSE
                 Trace_SYS.Message('*** Do not Start CRP ***');
               END IF;
               
               $IF (Component_Crp_SYS.INSTALLED) $THEN
                  IF (start_crp_calc_ AND routing_revision_ IS NOT NULL) THEN
                     IF png_ = '*' THEN
                        crp_source_db_ := Mach_Op_Load_Source_API.DB_MASTER_SCHEDULE; 
                     ELSE
                        crp_source_db_ := Mach_Op_Load_Source_API.DB_PROJECT_MASTER_SCHEDULE; 
                     END IF;
                     Crp_Mach_Operation_Util_API.Process_Crp(contract_        => contract_,
                                                             part_no_         => part_no_,
                                                             due_date_        => sub_order_rec_.ms_date,
                                                             due_counter_     => counter_,
                                                             crp_source_db_   => crp_source_db_,
                                                             bom_type_db_     => 'M',
                                                             rev_qty_due_     => req_qty_,
                                                             activity_seq_    => activity_seq_,
                                                             calendar_id_     => calendar_id_,
                                                             order_ref1_      => proposal_no_,
                                                             order_ref2_      => '*',
                                                             routing_rev_     => routing_revision_,
                                                             routing_alt_     => routing_alternative_no_,
                                                             start_date_      => NULL);
                     
                     prop_start_date_ := Crp_Mach_Operation_Util_API.Get_Min_Op_Start_Date(contract_       => contract_,
                                                                                           part_no_        => part_no_,
                                                                                           counter_        => counter_,
                                                                                           crp_source_db_  => crp_source_db_,
                                                                                           order_ref1_     => proposal_no_,
                                                                                           order_ref2_     => '*');
                     
                     Shop_Order_Prop_API.Update_Prop_Start_Date(proposal_no_     => proposal_no_,
                                                                prop_start_date_ => prop_start_date_);                
                  END IF;
               $END
               
               Ms_Receipt_API.Batch_Modify__(contract_, 
                                             part_no_,
                                             png_,
                                             1,
                                             ms_receipt_activity_seq_,
                                             sub_order_rec_.ms_date,
                                             sub_order_rec_.line_no,
                                             NULL,
                                             NULL,
                                             'UPDATE',
                                             prop_start_date_);
                     
               Supply_Order_Detail_API.Batch_New__ (
                   contract_           => contract_,
                   part_no_            => part_no_,
                   png_                => png_,
                   ms_set_             => 1,
                   ms_date_            => sub_order_rec_.ms_date,
                   line_no_            => sub_order_rec_.line_no,
                   activity_seq_       => ms_receipt_activity_seq_,
                   supply_order_type_  => 'SO',
                   supply_order_seq_   => NULL,                 
                   supply_order_no_    => proposal_no_,
                   supply_release_no_  => '1',
                   supply_sequence_no_ => '1',
                   order_qty_          => req_qty_ );
               
               IF png_ = '*' OR (png_ != '*' AND NOT inside_ptf_) THEN
                  Pegged_Supply_Demand_Util_API.Insert_Shop_Proposal__(contract_,
                                                                       part_no_,
                                                                       png_,
                                                                       1,
                                                                       ms_receipt_activity_seq_,
                                                                       proposal_no_);
               END IF;
            ELSE
               -- No buildable alternative was found
               IF NOT (Level_1_Message_API.Check_Exist_On_Date (
                             contract_          =>   contract_,
                             part_no_           =>   part_no_,
                             png_               =>   png_,
                             ms_set_            =>   1,
                             ms_date_           =>   sub_order_rec_.ms_date,
                             msg_code_          =>   'E540')) THEN
                  Level_1_Message_API.Batch_New__(
                     contract_      => contract_,
                     part_no_       => part_no_,
                     png_           => png_,
                     ms_set_        => 1,
                     ms_date_       => sub_order_rec_.ms_date,
                     order_no_      => NULL,
                     line_no_       => NULL,
                     release_no_    => NULL,
                     line_item_no_  => NULL,
                     order_type_db_ => NULL,
                     activity_seq_  => ms_receipt_activity_seq_,
                     msg_code_      => 'E540');                 
               END IF;
            END IF;
         END IF;
      END LOOP;
   
   EXCEPTION
      WHEN OTHERS THEN
         IF Error_SYS.Is_Foundation_Error(SQLCODE) THEN
            RAISE;
         END IF;
   
         Error_Sys.Appl_General (lu_name_, 'GENSHOPPROP: Error :P1 occurred while running LEVEL_1_FORECAST_UTIL_API.Generate_Shop_Proposal__ for Site :P2 PNG :P3.',
                                 SQLERRM, contract_||' / '||part_no_, png_);
   END Core;

BEGIN
   General_SYS.Init_Method(LEVEL_1_FORECAST_UTIL_API.lu_name_, 'LEVEL_1_FORECAST_UTIL_API', 'Generate_Shop_Proposal__');
   Core(contract_, part_no_, png_, ms_receipt_activity_seq_, split_manuf_acquired_, period_1_, period_2_, calendar_id_, start_crp_calc_, do_supply_arr_, inside_ptf_);
END Generate_Shop_Proposal__;


PROCEDURE Remove_Pur_Req__ (
   contract_             IN VARCHAR2,
   part_no_              IN VARCHAR2,
   png_                  IN VARCHAR2,
   demand_tf_            IN DATE,
   planning_tf_          IN DATE,
   pmps_run_seq_         IN NUMBER,
   activity_seq_         IN NUMBER )
IS
   
   PROCEDURE Core (
      contract_             IN VARCHAR2,
      part_no_              IN VARCHAR2,
      png_                  IN VARCHAR2,
      demand_tf_            IN DATE,
      planning_tf_          IN DATE,
      pmps_run_seq_         IN NUMBER,
      activity_seq_         IN NUMBER )
   IS
      req_line_state_           VARCHAR2(300);
      parent_date_              DATE;
      parent_line_no_           NUMBER;
      use_reqs_in_planning_     VARCHAR2(20) := Site_Mfgstd_Info_API.Get_Use_Rel_Pr_In_Planning_Db (contract_);
      pmps_req_code_            VARCHAR2(20) := Mpccom_Defaults_API.Get_Char_Value ('PMPS', 'REQUISITION_HEADER', 'REQUISITIONER_CODE');
   
      CURSOR get_sub_orders IS
         SELECT ms_date, line_no, sysgen_flag
         FROM ms_receipt_tab
         WHERE contract = contract_
         AND   part_no  = part_no_
         AND   png      = png_
         AND   ms_set   = 1
         AND   activity_seq = activity_seq_
         AND   ms_date >= demand_tf_
         AND   NVL(master_sched_rcpt, 0) > 0;
   
      CURSOR get_sup_order_dtls IS
         SELECT supply_order_no,
                supply_release_no,
                supply_sequence_no,
                supply_order_seq
         FROM supply_order_detail_tab
         WHERE contract          = contract_
         AND   part_no           = part_no_
         AND   png               = png_
         AND   ms_set            = 1
         AND   activity_seq      = activity_seq_
         AND   ms_date           = parent_date_
         AND   line_no           = parent_line_no_
         AND   supply_order_type = 'PO'
         AND   order_created     = 'FALSE';
   BEGIN
   
      FOR sub_order_rec_ IN get_sub_orders LOOP
         parent_date_ := sub_order_rec_.ms_date;
         parent_line_no_ := sub_order_rec_.line_no;
   
         FOR sup_dtls_rec_ IN get_sup_order_dtls LOOP
            -- Modified since the purchase requisition can have inquiry order created even in requisition line is not in Request Created.
            $IF Component_Purch_SYS.INSTALLED $THEN
               req_line_state_ := Purchase_Req_Line_API.Get_Requisition_Line_Objstate(sup_dtls_rec_.supply_order_no,
                                                                                      sup_dtls_rec_.supply_release_no,
                                                                                      sup_dtls_rec_.supply_sequence_no);
            $ELSE
               NULL;
            $END
   
            IF ((sub_order_rec_.ms_date >= demand_tf_ AND sub_order_rec_.ms_date <= planning_tf_) OR
                (sub_order_rec_.ms_date > planning_tf_ AND sub_order_rec_.sysgen_flag = 'N')) THEN
               -- Req line in state 'Authorized', 'Request Created', 'PO Created' and 'Partially Authorized', will
               -- be treated as supply, and MS should not create fixed ms receipt for them again.
               IF (req_line_state_ IN ('Authorized', 'Request Created', 'PO Created', 'Partially Authorized', 'Change Order Created'))
                  OR (use_reqs_in_planning_ = 'TRUE' AND req_line_state_ = 'Released') THEN
   
                  Supply_Order_Detail_API.Batch_Modify__ (
                     contract_           => contract_,
                     part_no_            => part_no_,
                     png_                => png_,
                     ms_set_             => 1,
                     activity_seq_       => activity_seq_,
                     ms_date_            => sub_order_rec_.ms_date,
                     line_no_            => sub_order_rec_.line_no,
                     supply_order_type_  => 'PO',
                     supply_order_seq_   => sup_dtls_rec_.supply_order_seq,                 
                     supply_order_no_    => NULL,
                     supply_release_no_  => NULL,
                     supply_sequence_no_ => NULL,
                     order_qty_          => NULL,
                     order_created_      => 'TRUE',
                     method_             => 'MAKE NULL' );
               ELSE -- Remove the supply connection
                  Supply_Order_Detail_API.Batch_Remove__ (
                     contract_          => contract_,
                     part_no_           => part_no_,
                     png_               => png_,
                     ms_set_            => 1,
                     activity_seq_      => activity_seq_,
                     ms_date_           => sub_order_rec_.ms_date,
                     line_no_           => sub_order_rec_.line_no,
                     supply_order_type_ => 'PO',
                     supply_order_seq_  => sup_dtls_rec_.supply_order_seq );
               END IF;
            END IF;
         END LOOP;
      END LOOP;
      
      $IF Component_Purch_SYS.INSTALLED $THEN
         IF png_ = '*' THEN 
            Purchase_Req_Line_Part_API.Remove_Requisition(contract_, part_no_);
         ELSE
            Purchase_Req_Line_Part_API.Remove_Png_Pmrp_Requisition(contract_, part_no_, pmps_run_seq_, pmps_req_code_);
         END IF;
      $END
   EXCEPTION
      WHEN OTHERS THEN
         IF Error_SYS.Is_Foundation_Error(SQLCODE) THEN
            RAISE;
         END IF;
   
         Error_Sys.Appl_General (lu_name_, 'REMOVEPURREQ: Error :P1 occurred while running LEVEL_1_FORECAST_UTIL_API.Remove_Pur_Req__ for Site :P2 PNG :P3.',
                                 SQLERRM, contract_||' / '||part_no_, png_);
   END Core;

BEGIN
   General_SYS.Init_Method(LEVEL_1_FORECAST_UTIL_API.lu_name_, 'LEVEL_1_FORECAST_UTIL_API', 'Remove_Pur_Req__');
   Core(contract_, part_no_, png_, demand_tf_, planning_tf_, pmps_run_seq_, activity_seq_);
END Remove_Pur_Req__;


PROCEDURE Generate_Pur_Req__ (
   contract_                   IN VARCHAR2,
   part_no_                    IN VARCHAR2,
   png_                        IN VARCHAR2,
   ms_receipt_activity_seq_    IN NUMBER,
   unit_meas_                  IN VARCHAR2,
   demand_tf_                  IN DATE,
   planning_tf_                IN DATE,
   inside_ptf_                 IN BOOLEAN DEFAULT TRUE )
IS
   
   PROCEDURE Core (
      contract_                   IN VARCHAR2,
      part_no_                    IN VARCHAR2,
      png_                        IN VARCHAR2,
      ms_receipt_activity_seq_    IN NUMBER,
      unit_meas_                  IN VARCHAR2,
      demand_tf_                  IN DATE,
      planning_tf_                IN DATE,
      inside_ptf_                 IN BOOLEAN DEFAULT TRUE )
   IS
      po_req_code_ VARCHAR2(20);
   BEGIN
      
      $IF Component_Purch_SYS.INSTALLED $THEN
         DECLARE
            part_supplier_collection_   Supply_Source_Part_Manager_API.Part_Supplier_Collection;
            loop_counter_               PLS_INTEGER;
            requisition_no_             VARCHAR2(120);
            line_no_                    VARCHAR2(200);
            release_no_                 VARCHAR2(200);
            order_code_                 VARCHAR2(20);
            mark_for_                   VARCHAR2(20) := NULL;
            req_qty_                    NUMBER;
            total_split_percentage_     NUMBER;
            multisite_pct_share_        NUMBER;
            remaining_qty_              NUMBER;
            qty_created_                NUMBER;
            supplier_qty_               NUMBER;
            excess_carryover_qty_       NUMBER := 0;
            demand_code_                VARCHAR2(200);
            activity_seq_               NUMBER;
            category_db_                VARCHAR2(20);
            multisite_planned_part_db_  VARCHAR2(20);
            purch_part_not_defined_     EXCEPTION;
   
            CURSOR get_sub_orders IS
               SELECT line_no, ms_date, master_sched_rcpt, vendor_no
               FROM ms_receipt_tab
               WHERE contract = contract_
               AND   part_no  = part_no_
               AND   png      = png_
               AND   ms_set   = 1
               AND   ms_date  BETWEEN demand_tf_ AND planning_tf_
               AND   NVL(master_sched_rcpt, 0) > 0
               ORDER BY ms_date;
            
            CURSOR get_supplier_info (vendor_no_ VARCHAR2) IS
               SELECT category_db, multisite_planned_part_db
               FROM Supply_Part_Sourcing_Pub
               WHERE contract  = contract_
               AND   part_no   = part_no_
               AND   vendor_no = vendor_no_;
            
            
         BEGIN
            IF NVL(Purchase_Part_API.Check_Exist (contract_, part_no_), 0) = 0 THEN
               RAISE purch_part_not_defined_;
            END IF;
   
            requisition_no_ := NULL;
            loop_counter_ := 1;
   
            FOR sub_order_rec_ IN get_sub_orders LOOP
               
               req_qty_ := sub_order_rec_.master_sched_rcpt;
               
               -- Purchase requisitions are created as the last step of the MS supply generation (Dist Order and SO Req are created earlier),
               -- therefore we can use this fact and just take the MsReceipt.master_sched_receipt and reduce it with
               -- supply already created.
               req_qty_ := req_qty_ - Supply_Order_Detail_API.Get_Total_Supply (
                                                                  contract_,
                                                                  part_no_,
                                                                  png_,
                                                                  1,
                                                                  sub_order_rec_.ms_date,
                                                                  sub_order_rec_.line_no );
   
               req_qty_ := Inventory_Part_API.Get_Calc_Rounded_Qty(contract_, part_no_, req_qty_ - excess_carryover_qty_);
   
   
               -- We do the supplier split right in this method (if there is any split)
               Supply_Source_Part_Manager_API.Collect_Supplier_List (part_supplier_collection_,
                                                                     contract_,
                                                                     part_no_,
                                                                     sub_order_rec_.ms_date,
                                                                     NULL);
   
   
               total_split_percentage_ := 0;
               IF part_supplier_collection_.COUNT > 0 THEN
                  FOR row_index IN part_supplier_collection_.FIRST .. part_supplier_collection_.LAST LOOP
                     total_split_percentage_ := total_split_percentage_ + part_supplier_collection_(row_index).split_percentage;
                  END LOOP;
               END IF;
               IF part_supplier_collection_.COUNT = 0 OR total_split_percentage_ = 0 THEN
                  part_supplier_collection_(0).vendor_no                  := NULL;
                  part_supplier_collection_(0).supplying_site             := NULL;
                  part_supplier_collection_(0).category_db                := 'E';
                  part_supplier_collection_(0).primary_vendor_db          := NULL;
                  part_supplier_collection_(0).multisite_planned_part_db  := 'NOT_MULTISITE_PLAN';
                  part_supplier_collection_(0).phase_in_date              := sub_order_rec_.ms_date;
                  part_supplier_collection_(0).phase_out_date             := NULL;
                  part_supplier_collection_(0).split_percentage           := 100;
                  part_supplier_collection_(0).std_multiple_qty           := 0;
               END IF;
   
               IF req_qty_ > 0 AND part_supplier_collection_.COUNT > 0 THEN
                  IF (loop_counter_ = 1) THEN
                     order_code_ := '1';
                     IF png_ = '*' THEN 
                        po_req_code_ := Mpccom_Defaults_API.Get_Char_Value('MSLEV1','REQUISITION_HEADER','REQUISITIONER_CODE');
                        demand_code_ := Order_Supply_Type_API.Get_Client_Value(0);
                        activity_seq_ := NULL;
                     ELSE
                        po_req_code_ := Mpccom_Defaults_API.Get_Char_Value ('PMPS', 'REQUISITION_HEADER', 'REQUISITIONER_CODE');
                        demand_code_ := Order_Supply_Type_API.Get_Client_Value(26);
                        activity_seq_ := ms_receipt_activity_seq_;                  
                     END IF;
                     -- Create a purchase_requisition_tab record (PO Req Head)
                     Purchase_Req_Util_API.New_Requisition(requisition_no_, order_code_, contract_, po_req_code_, mark_for_ );
                  END IF;
   
                  remaining_qty_ := req_qty_;
                  qty_created_   := 0;
                  
                  -- if vendor_no has a value PR should be generated directly from  ms_receipt_tab.
                  IF (sub_order_rec_.vendor_no IS NOT NULL) THEN
                     
                     OPEN get_supplier_info(sub_order_rec_.vendor_no);
                     FETCH get_supplier_info INTO category_db_, multisite_planned_part_db_;
                     CLOSE get_supplier_info;
                     
                     IF NOT(category_db_ = 'I' AND multisite_planned_part_db_ = 'MULTISITE_PLAN') THEN
   
                        line_no_ := NULL;
                        release_no_ := NULL;
                        Purchase_Req_Util_API.New_Line_Part (
                           line_no_             => line_no_,
                           release_no_          => release_no_,
                           requisition_no_      => requisition_no_,
                           contract_            => contract_,
                           part_no_             => part_no_,
                           unit_meas_           => unit_meas_,
                           original_qty_        => req_qty_,
                           wanted_receipt_date_ => sub_order_rec_.ms_date,
                           demand_code_         => demand_code_,
                           vendor_no_           => sub_order_rec_.vendor_no,
                           supplier_split_      => Supplier_Split_API.Decode('SPLIT'),
                           split_percentage_    => NVL(Supply_Source_Part_Manager_API.Get_Split_Ratio(sub_order_rec_.vendor_no, contract_, part_no_, sub_order_rec_.ms_date), 100),
                           requested_qty_       => req_qty_,
                           use_split_           => 0,
                           activity_seq_        => activity_seq_ );
   
                        Supply_Order_Detail_API.Batch_New__ (
                           contract_           => contract_,
                           part_no_            => part_no_,
                           png_                => png_,
                           ms_set_             => 1,
                           ms_date_            => sub_order_rec_.ms_date,
                           line_no_            => sub_order_rec_.line_no,
                           activity_seq_       => ms_receipt_activity_seq_,
                           supply_order_type_  => 'PO',
                           supply_order_seq_   => NULL,
                           supply_order_no_    => requisition_no_,
                           supply_release_no_  => line_no_,
                           supply_sequence_no_ => release_no_,
                           order_qty_          => req_qty_);
                        
                        IF png_ = '*' OR (png_ != '*' AND NOT inside_ptf_) THEN
                           Pegged_Supply_Demand_Util_API.Insert_Purch_Req__(contract_,
                                                                            part_no_,
                                                                            png_,
                                                                            1,
                                                                            ms_receipt_activity_seq_,
                                                                            requisition_no_,
                                                                            line_no_,
                                                                            release_no_);
                        END IF;
                     END IF;
                  ELSE
                     multisite_pct_share_ := Supply_Source_Part_Manager_API.Get_Multisite_Plan_Pct_Share(contract_,
                                                                                                         part_no_,
                                                                                                         sub_order_rec_.ms_date);
                     
                     FOR row_index IN part_supplier_collection_.FIRST .. part_supplier_collection_.LAST LOOP
                        line_no_ := NULL;
                        release_no_ := NULL;
                        supplier_qty_ := 0;
                        EXIT WHEN (remaining_qty_ <= 0);
                         
                        IF ((part_supplier_collection_(row_index).multisite_planned_part_db = 'NOT_MULTISITE_PLAN' OR activity_seq_ IS NOT NULL) AND (multisite_pct_share_ <100)) THEN
   
                        --                Trace_Sys.Message('Vendor No: '||part_supplier_collection_(row_index).vendor_no);
                        --                Trace_Sys.Message(part_supplier_collection_(row_index).split_percentage);
                        --                Trace_Sys.Message(multisite_pct_share_);
                        --                Trace_Sys.Message(req_qty_);
   
                           supplier_qty_ := ROUND(part_supplier_collection_(row_index).split_percentage/
                                                  (100 - multisite_pct_share_) * req_qty_ );
   
                           IF (supplier_qty_ > remaining_qty_) THEN
                              supplier_qty_ := remaining_qty_;
                           END IF;
   
                           IF supplier_qty_ > 0 THEN
                              -- Create a purchase_req_line_tab record
                              Purchase_Req_Util_API.New_Line_Part (
                                       line_no_             => line_no_,
                                       release_no_          => release_no_,
                                       requisition_no_      => requisition_no_,
                                       contract_            => contract_,
                                       part_no_             => part_no_,
                                       unit_meas_           => unit_meas_,
                                       original_qty_        => supplier_qty_,
                                       wanted_receipt_date_ => sub_order_rec_.ms_date,
                                       demand_code_         => demand_code_,
                                       vendor_no_           => part_supplier_collection_(row_index).vendor_no,
                                       supplier_split_      => Supplier_Split_API.Decode('SPLIT'),
                                       split_percentage_    => part_supplier_collection_(row_index).split_percentage,
                                       requested_qty_       => supplier_qty_,
                                       use_split_           => 0,
                                       activity_seq_        => activity_seq_ );
   
                              Supply_Order_Detail_API.Batch_New__ (
                                 contract_           => contract_,
                                 part_no_            => part_no_,
                                 png_                => png_,
                                 ms_set_             => 1,
                                 ms_date_            => sub_order_rec_.ms_date,
                                 line_no_            => sub_order_rec_.line_no,
                                 activity_seq_       => ms_receipt_activity_seq_,
                                 supply_order_type_  => 'PO',
                                 supply_order_seq_   => NULL,
                                 supply_order_no_    => requisition_no_,
                                 supply_release_no_  => line_no_,
                                 supply_sequence_no_ => release_no_,
                                 order_qty_          => supplier_qty_);
                           
                              IF png_ = '*' OR (png_ != '*' AND NOT inside_ptf_) THEN
                                 Pegged_Supply_Demand_Util_API.Insert_Purch_Req__(contract_,
                                                                                  part_no_,
                                                                                  png_,
                                                                                  1,
                                                                                  ms_receipt_activity_seq_,
                                                                                  requisition_no_,
                                                                                  line_no_,
                                                                                  release_no_);
                              END IF;
                              
                              remaining_qty_ := remaining_qty_ - supplier_qty_;
                              qty_created_ := NVL(qty_created_, 0) + supplier_qty_;
                           END IF;
                        END IF; -- Not Multisite Planned
                     END LOOP; -- End of suppliers loop
                  END IF;
                  excess_carryover_qty_ := GREATEST(NVL(qty_created_, 0) - NVL(req_qty_, 0), 0);
   
                  part_supplier_collection_.Delete;
   
                  loop_counter_ := loop_counter_ + 1;
               END IF;
            END LOOP;
         EXCEPTION
            WHEN purch_part_not_defined_ THEN
               Error_Sys.Appl_General (lu_name_, 'PURCHPARTNOTEXIST: LEVEL_1_FORECAST_UTIL_API.Generate_Pur_Req__, Cannot create purchase requsition, purchase part is not defined for Site :P1 Part No :P2.',
                                       contract_, part_no_);
            WHEN OTHERS THEN
               IF Error_SYS.Is_Foundation_Error(SQLCODE) THEN
                  RAISE;
               END IF;
               Error_Sys.Appl_General (lu_name_, 'GENERATEPURREQ: Error :P1 occurred while running LEVEL_1_FORECAST_UTIL_API.Generate_Pur_Req__ for Site :P2 PNG :P3.',
                                       SQLERRM, contract_||' / '||part_no_, png_);
         END;
      $ELSE
         NULL;
      $END
   END Core;

BEGIN
   General_SYS.Init_Method(LEVEL_1_FORECAST_UTIL_API.lu_name_, 'LEVEL_1_FORECAST_UTIL_API', 'Generate_Pur_Req__');
   Core(contract_, part_no_, png_, ms_receipt_activity_seq_, unit_meas_, demand_tf_, planning_tf_, inside_ptf_);
END Generate_Pur_Req__;


PROCEDURE Remove_Production_Schedules__ (
   contract_             IN VARCHAR2,
   part_no_              IN VARCHAR2,
   png_                  IN VARCHAR2,
   demand_tf_            IN DATE,
   planning_tf_          IN DATE )
IS
   
   PROCEDURE Core (
      contract_             IN VARCHAR2,
      part_no_              IN VARCHAR2,
      png_                  IN VARCHAR2,
      demand_tf_            IN DATE,
      planning_tf_          IN DATE )
   IS
      parent_date_         DATE;
      parent_line_no_      NUMBER;
      line_sched_status_   VARCHAR2(20);
   
      CURSOR get_sub_orders IS
         SELECT ms_date, line_no, sysgen_flag
         FROM   ms_receipt_tab
         WHERE  contract = contract_
         AND    part_no  = part_no_
         AND    png      = png_
         AND    ms_set   = 1
         AND    activity_seq = 0
         AND    ms_date  >= demand_tf_
         AND    NVL(master_sched_rcpt, 0) > 0;
   
      CURSOR get_sup_order_dtls IS
         SELECT supply_order_no,
                supply_order_seq
         FROM   supply_order_detail_tab
         WHERE  contract           = contract_
         AND    part_no            = part_no_
         AND    png                = png_
         AND    ms_set             = 1
         AND    activity_seq       = 0
         AND    ms_date            = parent_date_
         AND    line_no            = parent_line_no_
         AND    supply_order_type  = 'S'
         AND    order_created      = 'FALSE';
   BEGIN
   
      -- Firm non-firm cell schedules inside firm fence, then delete remaining
      -- non-firm cell schedules outside cell firm fence.
      $IF Component_Prosch_SYS.INSTALLED $THEN
         Line_Sched_Manager_Int_API.Firm_Line_Schedules(contract_, part_no_, 'MS');
         Line_Sched_Manager_Int_API.Clear_Line_Sched_Receipts(contract_, part_no_, 'MRP');
         Line_Sched_Manager_Int_API.Clear_Line_Sched_Receipts(contract_, part_no_, 'MS');
      $END
   
      FOR sub_order_rec_ IN get_sub_orders LOOP
         parent_date_ := sub_order_rec_.ms_date;
         parent_line_no_ := sub_order_rec_.line_no;
   
         FOR sup_dtls_rec_ IN get_sup_order_dtls LOOP
            
            $IF Component_Prosch_SYS.INSTALLED $THEN
               line_sched_status_ := Line_Sched_Status_API.Encode(Line_Sched_Receipt_API.Get_Line_Sched_Status(sup_dtls_rec_.supply_order_no));
            $END
   
            IF ((sub_order_rec_.ms_date >= demand_tf_ AND sub_order_rec_.ms_date <= planning_tf_) OR
                (sub_order_rec_.ms_date > planning_tf_ AND sub_order_rec_.sysgen_flag = 'N')) THEN
               IF (NVL(line_sched_status_, 'DuMmY') = 'FIRM') THEN
                  Supply_Order_Detail_API.Batch_Modify__ (
                     contract_           => contract_,
                     part_no_            => part_no_,
                     png_                => png_,
                     ms_set_             => 1,
                     activity_seq_       => 0,
                     ms_date_            => sub_order_rec_.ms_date,
                     line_no_            => sub_order_rec_.line_no,
                     supply_order_type_  => 'S',
                     supply_order_seq_   => sup_dtls_rec_.supply_order_seq,
                     supply_order_no_    => NULL,
                     supply_release_no_  => NULL,
                     supply_sequence_no_ => NULL,
                     order_qty_          => NULL,
                     order_created_      => 'TRUE',
                     method_             => 'MAKE NULL' );
               ELSE -- Remove the supply connection
                  Supply_Order_Detail_API.Batch_Remove__ (
                     contract_          => contract_,
                     part_no_           => part_no_,
                     png_               => png_,
                     ms_set_            => 1,
                     activity_seq_      => 0,
                     ms_date_           => sub_order_rec_.ms_date,
                     line_no_           => sub_order_rec_.line_no,
                     supply_order_type_ => 'S',
                     supply_order_seq_  => sup_dtls_rec_.supply_order_seq );
               END IF;
            END IF;
         END LOOP;
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         IF Error_SYS.Is_Foundation_Error(SQLCODE) THEN
            RAISE;
         END IF;
   
         Error_Sys.Appl_General (lu_name_, 'REMOVEPROSCH: Error :P1 occurred while running LEVEL_1_FORECAST_UTIL_API.Remove_Production_Schedules__ for Site :P2 Part No :P3.', SQLERRM, contract_, part_no_);
   END Core;

BEGIN
   General_SYS.Init_Method(LEVEL_1_FORECAST_UTIL_API.lu_name_, 'LEVEL_1_FORECAST_UTIL_API', 'Remove_Production_Schedules__');
   Core(contract_, part_no_, png_, demand_tf_, planning_tf_);
END Remove_Production_Schedules__;


PROCEDURE Gen_Production_Schedules__ (
   contract_             IN VARCHAR2,
   part_no_              IN VARCHAR2,
   png_                  IN VARCHAR2,
   ms_set_               IN NUMBER,
   split_manuf_acquired_ IN VARCHAR2,
   demand_tf_            IN DATE,
   planning_tf_          IN DATE,
   run_date_             IN DATE,
   calendar_id_          IN VARCHAR2,
   start_crp_calc_       IN BOOLEAN,
   do_supply_arr_        IN Supply_Collection )
IS
   
   PROCEDURE Core (
      contract_             IN VARCHAR2,
      part_no_              IN VARCHAR2,
      png_                  IN VARCHAR2,
      ms_set_               IN NUMBER,
      split_manuf_acquired_ IN VARCHAR2,
      demand_tf_            IN DATE,
      planning_tf_          IN DATE,
      run_date_             IN DATE,
      calendar_id_          IN VARCHAR2,
      start_crp_calc_       IN BOOLEAN,
      do_supply_arr_        IN Supply_Collection )
   IS
   
      max_sched_horizon_        NUMBER := NVL(Prod_Line_Part_Horizon_API.Get_Max_Sched_Horizon (
                                                 contract_,
                                                 part_no_ ), 0);
      max_sched_horizon_ctr_    NUMBER := Work_Time_Calendar_API.Get_Work_Day_Counter(calendar_id_, run_date_) + max_sched_horizon_;
      max_sched_horizon_date_   DATE   := NVL(TRUNC(Work_Time_Calendar_API.Get_Work_Day (
                                                       calendar_id_,
                                                       max_sched_horizon_ctr_ )), TRUNC(SYSDATE ));
   
      req_qty_           NUMBER;
      percent_mfd_       NUMBER;
   
      CURSOR get_sub_orders IS
         SELECT line_no, ms_date, master_sched_rcpt
         FROM   ms_receipt_tab
         WHERE  contract = contract_
         AND    part_no  = part_no_
         AND    png      = png_
         AND    ms_set   = ms_set_
         AND    ms_date BETWEEN demand_tf_ AND planning_tf_
         AND    NVL(master_sched_rcpt, 0) > 0
         ORDER BY ms_date;
   
   BEGIN
   
      FOR sub_order_rec_ IN get_sub_orders LOOP
   
         IF (sub_order_rec_.ms_date <= max_sched_horizon_date_) THEN
   
            -- If there are any supplies that have been converted to orders/firm schedules subtract that firm/released supply below.
            IF (split_manuf_acquired_ = 'SPLIT') THEN
               percent_mfd_ := NVL(Inventory_Part_Planning_API.Get_Percent_Manufactured(contract_, part_no_), 0);
               req_qty_ := sub_order_rec_.master_sched_rcpt * (percent_mfd_/100);
            ELSE
               req_qty_ := sub_order_rec_.master_sched_rcpt;
            END IF;
   
            req_qty_ := req_qty_ - Supply_Order_Detail_API.Get_Supply_Converted_To_Order (
                                                            contract_,
                                                            part_no_,
                                                            png_,
                                                            ms_set_,
                                                            sub_order_rec_.ms_date,
                                                            sub_order_rec_.line_no );
   
            -- The distribution orders are treated as firm supply immediately when they are created so we need add this
            -- qty back to req_qty_.
            IF do_supply_arr_.COUNT > 0 THEN
               FOR row_index IN do_supply_arr_.FIRST .. do_supply_arr_.LAST LOOP
                  IF do_supply_arr_(row_index).ms_date = sub_order_rec_.ms_date AND
                     do_supply_arr_(row_index).line_no = sub_order_rec_.line_no THEN
                     req_qty_ := req_qty_ + do_supply_arr_(row_index).supply_qty;
                     EXIT;
                  END IF;
               END LOOP;
            END IF;
   
            req_qty_ := Inventory_Part_API.Get_Calc_Rounded_Qty(contract_, part_no_, req_qty_);
   
            IF req_qty_ > 0 THEN
               Create_Line_Sched_Receipts___ (contract_,
                                              part_no_,
                                              png_,
                                              ms_set_,
                                              sub_order_rec_.line_no,
                                              sub_order_rec_.ms_date,
                                              calendar_id_,
                                              req_qty_,
                                              start_crp_calc_);
            END IF;
         END IF;
      END LOOP;
   
   EXCEPTION
      WHEN OTHERS THEN
         IF Error_SYS.Is_Foundation_Error(SQLCODE) THEN
            RAISE;
         END IF;
   
         Error_Sys.Appl_General (lu_name_, 'GENPROSCH: Error :P1 occurred while running LEVEL_1_FORECAST_UTIL_API.Gen_Production_Schedules__ for Site :P2 Part No :P3.', SQLERRM, contract_, part_no_);
   END Core;

BEGIN
   General_SYS.Init_Method(LEVEL_1_FORECAST_UTIL_API.lu_name_, 'LEVEL_1_FORECAST_UTIL_API', 'Gen_Production_Schedules__');
   Core(contract_, part_no_, png_, ms_set_, split_manuf_acquired_, demand_tf_, planning_tf_, run_date_, calendar_id_, start_crp_calc_, do_supply_arr_);
END Gen_Production_Schedules__;


PROCEDURE Remove_Do__ (
   contract_             IN VARCHAR2,
   part_no_              IN VARCHAR2,
   png_                  IN VARCHAR2,
   demand_tf_            IN DATE,
   planning_tf_          IN DATE )
IS
   
   PROCEDURE Core (
      contract_             IN VARCHAR2,
      part_no_              IN VARCHAR2,
      png_                  IN VARCHAR2,
      demand_tf_            IN DATE,
      planning_tf_          IN DATE )
   IS
      parent_date_          DATE;
      parent_line_no_       NUMBER;
      do_state_             VARCHAR2(60);
      
      info_                 VARCHAR2(2000);
      msreq_code_           VARCHAR2(20) := Mpccom_Defaults_API.Get_Char_Value (
                                                'MSLEV1',
                                                'REQUISITION_HEADER',
                                                'REQUISITIONER_CODE');
      mrpreq_code_          VARCHAR2(20) := Mpccom_Defaults_API.Get_Char_Value (
                                                'MRPREQ',
                                                'REQUISITION_HEADER',
                                                'REQUISITIONER_CODE');
   
      CURSOR get_sub_orders IS
         SELECT ms_date, line_no, sysgen_flag
         FROM   ms_receipt_tab
         WHERE  contract = contract_
         AND    part_no  = part_no_
         AND    png      = png_
         AND    ms_set   = 1
         AND    activity_seq = 0
         AND    ms_date >= demand_tf_
         AND    NVL(master_sched_rcpt, 0) > 0;
   
      CURSOR get_sup_order_dtls IS
         SELECT supply_order_seq,
                supply_order_no,
                supply_release_no,
                supply_sequence_no
         FROM   supply_order_detail_tab
         WHERE  contract           = contract_
         AND    part_no            = part_no_
         AND    png                = png_
         AND    ms_set             = 1
         AND    activity_seq       = 0
         AND    ms_date            = parent_date_
         AND    line_no            = parent_line_no_
         AND    supply_order_type  = 'DO';
         -- AND    order_created      = 'FALSE';
   
   BEGIN
   
      FOR sub_order_rec_ IN get_sub_orders LOOP
         parent_date_ := sub_order_rec_.ms_date;
         parent_line_no_ := sub_order_rec_.line_no;
   
         FOR sup_dtls_rec_ IN get_sup_order_dtls LOOP
   
            do_state_ := NULL;
            
            $IF Component_Disord_SYS.INSTALLED $THEN
               do_state_ := Distribution_Order_API.Get_Objstate(sup_dtls_rec_.supply_order_no);
            $END
   
            IF ((sub_order_rec_.ms_date >= demand_tf_ AND sub_order_rec_.ms_date <= planning_tf_) OR
                (sub_order_rec_.ms_date > planning_tf_ AND sub_order_rec_.sysgen_flag = 'N')) THEN
               IF do_state_ IN ('Released', 'Reserved', 'Picked', 'In Transit', 'Arrived', 'Received', 'Closed' , 'Stopped', 'Cancelled') THEN
                  -- If the DO has been released, we must update the order_created flag.
   
                  Supply_Order_Detail_API.Batch_Modify__ (
                     contract_           => contract_,
                     part_no_            => part_no_,
                     png_                => png_,
                     ms_set_             => 1,
                     activity_seq_       => 0,
                     ms_date_            => sub_order_rec_.ms_date,
                     line_no_            => sub_order_rec_.line_no,
                     supply_order_type_  => 'DO',
                     supply_order_seq_   => sup_dtls_rec_.supply_order_seq,
                     supply_order_no_    => NULL,
                     supply_release_no_  => NULL,
                     supply_sequence_no_ => NULL,
                     order_qty_          => NULL,
                     order_created_      => 'TRUE',
                     method_             => 'MAKE NULL' );
               ELSE -- Remove the supply connection
                  Supply_Order_Detail_API.Batch_Remove__ (
                     contract_          => contract_,
                     part_no_           => part_no_,
                     png_               => png_,
                     ms_set_            => 1,
                     activity_seq_      => 0,
                     ms_date_           => sub_order_rec_.ms_date,
                     line_no_           => parent_line_no_,
                     supply_order_type_ => 'DO',
                     supply_order_seq_  => sup_dtls_rec_.supply_order_seq );
               END IF;
            END IF;
         END LOOP;
      END LOOP;
   
      -- Remove the unreleased distribution orders.
      $IF Component_Disord_SYS.INSTALLED $THEN
         Distribution_Order_Util_API.Delete_Unreleased_Dos (
                      info_,
                      contract_,
                      msreq_code_, part_no_ );
         Distribution_Order_Util_API.Delete_Unreleased_Dos (
                      info_,
                      contract_,
                      mrpreq_code_, part_no_ );
      $END
   EXCEPTION
      WHEN OTHERS THEN
         IF Error_SYS.Is_Foundation_Error(SQLCODE) THEN
            RAISE;
         END IF;
   
         Error_Sys.Appl_General (lu_name_, 'REMOVEDO: Error :P1 occurred while running LEVEL_1_FORECAST_UTIL_API.Remove_Do__ for Site :P2 Part No :P3.', SQLERRM, contract_, part_no_);
   END Core;

BEGIN
   General_SYS.Init_Method(LEVEL_1_FORECAST_UTIL_API.lu_name_, 'LEVEL_1_FORECAST_UTIL_API', 'Remove_Do__');
   Core(contract_, part_no_, png_, demand_tf_, planning_tf_);
END Remove_Do__;


PROCEDURE Generate_Do__ (
   applied_dis_ord_date_    OUT    DATE,
   adjusted_increment_qty_  IN OUT NOCOPY NUMBER,
   do_supply_arr_           IN OUT NOCOPY Supply_Collection,
   contract_                IN     VARCHAR2,
   part_no_                 IN     VARCHAR2,
   png_                     IN     VARCHAR2,
   ms_set_                  IN     NUMBER,
   split_manuf_acquired_    IN     VARCHAR2,
   demand_tf_               IN     DATE,
   planning_tf_             IN     DATE,
   calendar_id_             IN     VARCHAR2 )
IS
   
   PROCEDURE Core (
      applied_dis_ord_date_    OUT    DATE,
      adjusted_increment_qty_  IN OUT NOCOPY NUMBER,
      do_supply_arr_           IN OUT NOCOPY Supply_Collection,
      contract_                IN     VARCHAR2,
      part_no_                 IN     VARCHAR2,
      png_                     IN     VARCHAR2,
      ms_set_                  IN     NUMBER,
      split_manuf_acquired_    IN     VARCHAR2,
      demand_tf_               IN     DATE,
      planning_tf_             IN     DATE,
      calendar_id_             IN     VARCHAR2 )
   IS
      remaining_qty_             NUMBER;
      qty_created_               NUMBER;
      total_do_qty_              NUMBER;
      planned_due_date_          DATE;
      supplier_qty_              NUMBER;
      do_order_no_               VARCHAR2(12);
      network_id_                VARCHAR2(10) := NULL;
      excess_carryover_qty_      NUMBER;
      make_qty_                     NUMBER;
      make_qty_converted_to_order_  NUMBER;
      percent_mfd_                  NUMBER;
      order_qty_                    NUMBER;
      total_created_do_qty_         NUMBER := 0;
      ms_rcpt_row_cnt_              PLS_INTEGER := 0;
      supply_date_                  DATE;
      site_date_                    DATE;
      msreq_code_ VARCHAR2(20) := Mpccom_Defaults_API.Get_Char_Value ('MSLEV1',
                                                                      'REQUISITION_HEADER',
                                                                      'REQUISITIONER_CODE');
      CURSOR get_sub_orders IS
         SELECT line_no, ms_date, master_sched_rcpt, vendor_no
         FROM ms_receipt_tab
         WHERE contract = contract_
         AND   part_no  = part_no_
         AND   png      = png_
         AND   ms_set   = 1
         AND   ms_date BETWEEN demand_tf_ AND planning_tf_
         AND   NVL(master_sched_rcpt, 0) > 0
         ORDER BY ms_date;
   
   BEGIN
      
      $IF Component_Disord_SYS.INSTALLED $THEN
         DECLARE
            part_supplier_collection_  Supply_Source_Part_Manager_API.Part_Supplier_Collection;
            -- Bug 122356, start
            part_supplier_collection_tmp_ Supply_Source_Part_Manager_API.Part_Supplier_Collection;
            -- Bug 122356, end
            category_db_               VARCHAR2(20);
            multisite_planned_part_db_ VARCHAR2(20);
            supplying_site_            VARCHAR2(5);
            
            -- Bug 122356, start
            cur_row_                   PLS_INTEGER;
            total_split_percentage_    NUMBER;
            part_status_               VARCHAR2(20);
            part_stat_rec_             INVENTORY_PART_STATUS_PAR_API.Public_Rec;
            -- Bug 122356, end
                     
            CURSOR get_supplier_info (vendor_no_ VARCHAR2) IS
               SELECT category_db, multisite_planned_part_db, supplying_site
               FROM Supply_Part_Sourcing_Pub
               WHERE contract  = contract_
               AND   part_no   = part_no_
               AND   vendor_no = vendor_no_;
               
         BEGIN 
            excess_carryover_qty_ := 0;
            site_date_ := Site_API.Get_Site_Date(contract_);
   
            FOR sub_order_rec_ IN get_sub_orders LOOP
               ms_rcpt_row_cnt_ := ms_rcpt_row_cnt_ + 1;
   
               -- If there are any reqs that have been converted to orders subtract that firm/released supply below.
               IF (split_manuf_acquired_ = 'SPLIT') THEN
                  percent_mfd_ := NVL(Inventory_Part_Planning_API.Get_Percent_Manufactured (contract_, part_no_), 0);
                  make_qty_ := sub_order_rec_.master_sched_rcpt * (percent_mfd_/100);
   
                  make_qty_converted_to_order_ := Supply_Order_Detail_API.Get_Supply_Converted_To_Order (
                                                                     contract_,
                                                                     part_no_,
                                                                     png_,
                                                                     1,
                                                                     sub_order_rec_.ms_date,
                                                                     sub_order_rec_.line_no,
                                                                     'SO') +
                                                  Supply_Order_Detail_API.Get_Supply_Converted_To_Order (
                                                                     contract_,
                                                                     part_no_,
                                                                     png_,
                                                                     1,
                                                                     sub_order_rec_.ms_date,
                                                                     sub_order_rec_.line_no,
                                                                     'S');
                  make_qty_ := GREATEST(make_qty_ - make_qty_converted_to_order_, 0);
               ELSE
                  make_qty_ := 0;
               END IF;
   
               total_do_qty_ := sub_order_rec_.master_sched_rcpt - Supply_Order_Detail_API.Get_Supply_Converted_To_Order (
                                                                     contract_,
                                                                     part_no_,
                                                                     png_,
                                                                     1,
                                                                     sub_order_rec_.ms_date,
                                                                     sub_order_rec_.line_no ) - make_qty_;
   
               total_do_qty_ := total_do_qty_ - excess_carryover_qty_;
   
               total_created_do_qty_ := 0;
   
               Supply_Source_Part_Manager_API.Collect_Supplier_List (part_supplier_collection_tmp_,
                                                                     contract_,
                                                                     part_no_,
                                                                     sub_order_rec_.ms_date,
                                                                     NULL);
               -- Bug 122356, start
               IF part_supplier_collection_tmp_.COUNT > 0 THEN
                  FOR row_index IN part_supplier_collection_tmp_.FIRST .. part_supplier_collection_tmp_.LAST LOOP
                     part_status_ := Inventory_Part_API.Get_Part_Status(part_supplier_collection_tmp_(row_index).supplying_site, part_no_);
                     part_stat_rec_  := Inventory_Part_Status_Par_API.Get(part_status_);
                     IF ((part_supplier_collection_tmp_(row_index).category_db = 'E') OR (part_supplier_collection_tmp_(row_index).category_db = 'I' AND part_stat_rec_.demand_flag = 'Y')) THEN
                        cur_row_ := NVL(part_supplier_collection_.LAST, 0) + 1;
                        part_supplier_collection_(cur_row_).vendor_no                  := part_supplier_collection_tmp_(row_index).vendor_no;
                        part_supplier_collection_(cur_row_).supplying_site             := part_supplier_collection_tmp_(row_index).supplying_site;
                        part_supplier_collection_(cur_row_).category_db                := part_supplier_collection_tmp_(row_index).category_db;
                        part_supplier_collection_(cur_row_).primary_vendor_db          := part_supplier_collection_tmp_(row_index).primary_vendor_db;
                        part_supplier_collection_(cur_row_).multisite_planned_part_db  := part_supplier_collection_tmp_(row_index).multisite_planned_part_db;
                        part_supplier_collection_(cur_row_).phase_in_date              := part_supplier_collection_tmp_(row_index).phase_in_date;
                        part_supplier_collection_(cur_row_).phase_out_date             := part_supplier_collection_tmp_(row_index).phase_out_date;
                        part_supplier_collection_(cur_row_).split_percentage           := part_supplier_collection_tmp_(row_index).split_percentage;
                        part_supplier_collection_(cur_row_).std_multiple_qty           := part_supplier_collection_tmp_(row_index).std_multiple_qty;                    
                     END IF;                  
                  END LOOP;
               END IF;
               part_supplier_collection_tmp_.Delete;
               
               total_split_percentage_ := 0;
               IF part_supplier_collection_.COUNT > 0 THEN
                  FOR row_index IN part_supplier_collection_.FIRST .. part_supplier_collection_.LAST LOOP
                     total_split_percentage_ := total_split_percentage_ + part_supplier_collection_(row_index).split_percentage;
                  END LOOP;
               END IF;
               
               IF total_split_percentage_ = 0 THEN               
                  total_split_percentage_ := 100;
               END IF;
               -- Bug 122356, end
   
               IF total_do_qty_ > 0 AND part_supplier_collection_.COUNT > 0 THEN
                  remaining_qty_ := total_do_qty_;
                  qty_created_   := 0;
                  
                  -- if vendor_no has a value DO should be generated directly from  ms_receipt_tab.
                  IF (sub_order_rec_.vendor_no IS NOT NULL) THEN
                     
                     OPEN get_supplier_info(sub_order_rec_.vendor_no);
                     FETCH get_supplier_info INTO category_db_, multisite_planned_part_db_, supplying_site_;
                     CLOSE get_supplier_info;
                     
                     IF (category_db_ = 'I' AND multisite_planned_part_db_ = 'MULTISITE_PLAN') THEN
                        order_qty_ := Inventory_Part_API.Get_Calc_Rounded_Qty(contract_, part_no_, total_do_qty_);
   
                        Distribution_Order_API.Create_Distribution_Order (
                                       planned_due_date_     => planned_due_date_,
                                       order_no_             => do_order_no_,
                                       qty_to_move_          => order_qty_,
                                       supply_site_          => supplying_site_,
                                       demand_site_          => contract_,
                                       part_no_              => part_no_,
                                       requisitioner_code_   => msreq_code_,
                                       network_id_           => network_id_,
                                       planned_receipt_date_ => sub_order_rec_.ms_date,
                                       demand_site_date_     => site_date_);
                     
                        IF (planned_due_date_ < site_date_) THEN
                           -- DO will not be created.
                           IF NOT (Level_1_Message_API.Check_Exist_On_Date (
                                         contract_       => contract_,
                                         part_no_        => part_no_,
                                         png_            => png_,
                                         ms_set_         => 1,
                                         ms_date_        => sub_order_rec_.ms_date,
                                         msg_code_       => 'E541')) THEN
                              Level_1_Message_API.Batch_New__(
                                 contract_      => contract_,
                                 part_no_       => part_no_,
                                 png_           => png_,
                                 ms_set_        => 1,
                                 ms_date_       => sub_order_rec_.ms_date,
                                 order_no_      => NULL,
                                 line_no_       => NULL,
                                 release_no_    => NULL,
                                 line_item_no_  => NULL,
                                 order_type_db_ => NULL,
                                 activity_seq_  => NULL,
                                 msg_code_      => 'E541');                                 
                           END IF;
   
                        ELSE
                           Supply_Order_Detail_API.Batch_New__ (
                                 contract_           => contract_,
                                 part_no_            => part_no_,
                                 png_                => png_,
                                 ms_set_             => 1,
                                 ms_date_            => sub_order_rec_.ms_date,
                                 line_no_            => sub_order_rec_.line_no,
                                 activity_seq_       => 0,
                                 supply_order_type_  => 'DO',
                                 supply_order_seq_   => NULL,
                                 supply_order_no_    => do_order_no_,
                                 supply_release_no_  => '1',
                                 supply_sequence_no_ => '1',
                                 order_qty_          => order_qty_,
                                 order_created_      => 'TRUE'); -- Set it to created, coz in below call we will make a snapshot of this.
                           -- Make a snapshot of this DO order.
                           Pegged_Supply_Demand_Util_API.Insert_Do_Order__(supply_date_,
                                                                           contract_,
                                                                           part_no_,
                                                                           png_,
                                                                           ms_set_,
                                                                           do_order_no_,
                                                                           calendar_id_);
   
                           total_created_do_qty_ := total_created_do_qty_ + order_qty_;
                           -- The DO might have been moved outside PTF
                           IF NVL(supply_date_, TRUNC(SYSDATE)) > planning_tf_ THEN
                              adjusted_increment_qty_ := adjusted_increment_qty_ + order_qty_;
                              applied_dis_ord_date_ :=  supply_date_;
                           END IF;
                        END IF;
                     END IF;
                  ELSE 
                     FOR i IN part_supplier_collection_.FIRST .. part_supplier_collection_.LAST LOOP
                        supplier_qty_ := 0;
                        EXIT WHEN (remaining_qty_ <= 0);
   
                        IF (part_supplier_collection_(i).category_db = 'I' AND
                            part_supplier_collection_(i).multisite_planned_part_db = 'MULTISITE_PLAN') THEN
   
                           supplier_qty_ := ROUND(part_supplier_collection_(i).split_percentage/total_split_percentage_ * total_do_qty_);
   
                           IF (supplier_qty_ > remaining_qty_) THEN
                              supplier_qty_ := remaining_qty_;
                           END IF;
   
                           IF supplier_qty_ > 0 THEN
   
                              order_qty_ := Inventory_Part_API.Get_Calc_Rounded_Qty(contract_, part_no_, supplier_qty_);
   
                              Distribution_Order_API.Create_Distribution_Order (
                                          planned_due_date_     => planned_due_date_,
                                          order_no_             => do_order_no_,
                                          qty_to_move_          => order_qty_,
                                          supply_site_          => part_supplier_collection_(i).supplying_site,
                                          demand_site_          => contract_,
                                          part_no_              => part_no_,
                                          requisitioner_code_   => msreq_code_,
                                          network_id_           => network_id_,
                                          planned_receipt_date_ => sub_order_rec_.ms_date,
                                          demand_site_date_     => site_date_);
   
                              IF (planned_due_date_ < site_date_) THEN
                                 -- DO will not be created.
                                 IF NOT (Level_1_Message_API.Check_Exist_On_Date (
                                               contract_       => contract_,
                                               part_no_        => part_no_,
                                               png_            => png_,
                                               ms_set_         => 1,
                                               ms_date_        => sub_order_rec_.ms_date,
                                               msg_code_       => 'E541')) THEN
                                    Level_1_Message_API.Batch_New__(
                                       contract_      => contract_,
                                       part_no_       => part_no_,
                                       png_           => png_,
                                       ms_set_        => 1,
                                       ms_date_       => sub_order_rec_.ms_date,
                                       order_no_      => NULL,
                                       line_no_       => NULL,
                                       release_no_    => NULL,
                                       line_item_no_  => NULL,
                                       order_type_db_ => NULL,
                                       activity_seq_  => NULL,
                                       msg_code_      => 'E541');                                 
                                 END IF;
   
                              ELSE
                                 Supply_Order_Detail_API.Batch_New__ (
                                       contract_           => contract_,
                                       part_no_            => part_no_,
                                       png_                => png_,
                                       ms_set_             => 1,
                                       ms_date_            => sub_order_rec_.ms_date,
                                       line_no_            => sub_order_rec_.line_no,
                                       activity_seq_       => 0,
                                       supply_order_type_  => 'DO',
                                       supply_order_seq_   => NULL,
                                       supply_order_no_    => do_order_no_,
                                       supply_release_no_  => '1',
                                       supply_sequence_no_ => '1',
                                       order_qty_          => order_qty_,
                                       order_created_      => 'TRUE'); -- Set it to created, coz in below call we will make a snapshot of this.
                                 -- Make a snapshot of this DO order.
                                 Pegged_Supply_Demand_Util_API.Insert_Do_Order__(supply_date_,
                                                                                 contract_,
                                                                                 part_no_,
                                                                                 png_,
                                                                                 ms_set_,
                                                                                 do_order_no_,
                                                                                 calendar_id_);
   
                                 total_created_do_qty_ := total_created_do_qty_ + order_qty_;
                                 -- The DO might have been moved outside PTF
                                 IF NVL(supply_date_, TRUNC(SYSDATE)) > planning_tf_ THEN
                                    adjusted_increment_qty_ := adjusted_increment_qty_ + order_qty_;
                                    applied_dis_ord_date_ :=  supply_date_;
                                 END IF;
   
                                 remaining_qty_ := remaining_qty_ - order_qty_;
                                 qty_created_ := NVL(qty_created_, 0) + order_qty_;
                              END IF;
                           END IF;
                        END IF; -- Is Multisite and Internal
                     END LOOP; -- End of suppliers loop
                     excess_carryover_qty_ := GREATEST(NVL(qty_created_, 0) - NVL(total_do_qty_, 0), 0);
                  END IF;
               END IF;
               part_supplier_collection_.Delete;
   
               do_supply_arr_(ms_rcpt_row_cnt_).ms_date := sub_order_rec_.ms_date;
               do_supply_arr_(ms_rcpt_row_cnt_).line_no := sub_order_rec_.line_no;
               do_supply_arr_(ms_rcpt_row_cnt_).supply_qty := total_created_do_qty_;
            END LOOP;
         END;
      $ELSE
         NULL;
      $END
   END Core;

BEGIN
   General_SYS.Init_Method(LEVEL_1_FORECAST_UTIL_API.lu_name_, 'LEVEL_1_FORECAST_UTIL_API', 'Generate_Do__');
   Core(applied_dis_ord_date_, adjusted_increment_qty_, do_supply_arr_, contract_, part_no_, png_, ms_set_, split_manuf_acquired_, demand_tf_, planning_tf_, calendar_id_);
END Generate_Do__;


PROCEDURE Schedule_Import_Forecast__ (
   attrib_ IN VARCHAR2 )
IS
   
   PROCEDURE Core (
      attrib_ IN VARCHAR2 )
   IS
      contract_        VARCHAR2(5);
      part_no_         VARCHAR2(25);
      budget_forecast_ VARCHAR2(1);
      target_ms_set_   NUMBER;
      period_length_   NUMBER;
      start_date_      DATE;
      end_date_        DATE;
      distribution_    NUMBER;
      ptf_copy_        NUMBER;   
      attrib_loc_      VARCHAR2(2000);
      calendar_id_     VARCHAR2(10);
      ptr_             NUMBER;
      name_            VARCHAR2(30);
      value_           VARCHAR2(2000);   
      scenario_id_     NUMBER;
      default_site_    VARCHAR2(5);
   
   BEGIN
      ptr_ := NULL;
      WHILE (Client_SYS.Get_Next_From_Attr(attrib_, ptr_, name_, value_)) LOOP
         IF (name_ = 'CONTRACT') THEN
            contract_ := nvl(value_,'%');
         ELSIF (name_ = 'PART_NO') THEN
            part_no_ := nvl(value_,'%');
         ELSIF (name_ = 'TARGET_MS_SET') THEN
            target_ms_set_ := TO_NUMBER (value_);
         ELSIF (name_ = 'PERIOD_LENGTH') THEN
            period_length_ := TO_NUMBER(value_);
         ELSIF (name_ = 'START_DATE') THEN
            start_date_ := Client_SYS.Attr_Value_To_Date(value_);
         ELSIF (name_ = 'END_DATE') THEN
            end_date_ := Client_SYS.Attr_Value_To_Date(value_);
         ELSIF (name_ = 'DISTRIBUTION') THEN
            distribution_ := TO_NUMBER(value_);
         ELSIF (name_ = 'PTF_COPY') THEN
            ptf_copy_ := TO_NUMBER(value_);
         ELSIF (name_ = 'BUDGET_FORECAST') THEN
            budget_forecast_ := value_;
         ELSIF (name_ = 'SCENARIO_ID') THEN
            scenario_id_ := TO_NUMBER (value_);
         ELSE
            Error_SYS.Item_Not_Exist(lu_name_, name_, value_);
         END IF;
      END LOOP;
   
      IF start_date_ IS NULL THEN
         default_site_ := User_Default_API.Get_Contract;
         IF contract_ = '%' THEN
            calendar_id_ := Site_API.Get_Manuf_Calendar_Id(default_site_);
            start_date_ := Site_API.Get_Site_Date(default_site_);
         ELSE
            calendar_id_ := nvl(Site_API.Get_Manuf_Calendar_Id( contract_ ), Site_API.Get_Manuf_Calendar_Id(default_site_));
            start_date_ := nvl(Site_API.Get_Site_Date( contract_ ), Site_API.Get_Site_Date( default_site_ ));
         END IF;
      END IF;
   
      IF end_date_ IS NULL THEN      
         end_date_ := start_date_ + period_length_;
      END IF;
   
      Client_SYS.Clear_Attr(attrib_loc_);
      Client_SYS.Add_To_Attr('CONTRACT', contract_, attrib_loc_);
      Client_SYS.Add_To_Attr('PART_NO', part_no_, attrib_loc_);
      Client_SYS.Add_To_Attr('TARGET_MS_SET', target_ms_set_, attrib_loc_);
      Client_SYS.Add_To_Attr('START_DATE', to_char(start_date_,'YYYYMMDDHH24MISS'), attrib_loc_);
      Client_SYS.Add_To_Attr('END_DATE', to_char(end_date_,'YYYYMMDDHH24MISS'), attrib_loc_);
      Client_SYS.Add_To_Attr('DISTRIBUTION', to_char(distribution_), attrib_loc_);
      Client_SYS.Add_To_Attr('PTF_COPY', to_char(ptf_copy_), attrib_loc_);
      Client_SYS.Add_To_Attr('BUDGET_FORECAST', budget_forecast_, attrib_loc_);   
      Client_SYS.Add_To_Attr('SCENARIO_ID', scenario_id_, attrib_loc_);
   
      IF (Transaction_SYS.Is_Session_Deferred()) THEN
         Level_1_Onhand_Util_API.Import_Forecast__(attrib_loc_);
      ELSE
         Transaction_SYS.Deferred_Call(
            'Level_1_Onhand_Util_API.Import_Forecast__',
             attrib_loc_,
             Language_SYS.Translate_Constant(lu_name_, 'LEV1IMPORT: Level 1 Import Forecast.'));
      END IF;
   
   END Core;

BEGIN
   General_SYS.Init_Method(LEVEL_1_FORECAST_UTIL_API.lu_name_, 'LEVEL_1_FORECAST_UTIL_API', 'Schedule_Import_Forecast__');
   Core(attrib_);
END Schedule_Import_Forecast__;

-----------------------------------------------------------------------------
-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------
-----------------------------------------------------------------------------

PROCEDURE Create_Line_Sched_Receipts___ (
   contract_      IN VARCHAR2,
   part_no_       IN VARCHAR2,
   png_           IN VARCHAR2,
   ms_set_        IN NUMBER,
   line_no_       IN NUMBER,
   due_date_      IN DATE,
   manuf_calendar_ IN VARCHAR2,
   qty_due_       IN NUMBER,
   start_crp_calc_ IN BOOLEAN )
IS
   
   PROCEDURE Core (
      contract_      IN VARCHAR2,
      part_no_       IN VARCHAR2,
      png_           IN VARCHAR2,
      ms_set_        IN NUMBER,
      line_no_       IN NUMBER,
      due_date_      IN DATE,
      manuf_calendar_ IN VARCHAR2,
      qty_due_       IN NUMBER,
      start_crp_calc_ IN BOOLEAN )
   IS
      line_sched_receipt_id_   VARCHAR2(12);
      horizon_id_              VARCHAR2(12);
      sched_frac_              VARCHAR2(20);
      qty_scheduled_           NUMBER;
      local_due_date_          DATE;
      calendar_id_             VARCHAR2(10);
      prod_line_location_      VARCHAR2(35);
      routing_revision_no_     VARCHAR2(6);
      routing_alternative_no_  VARCHAR2(20);
   BEGIN
      local_due_date_ := due_date_;
   
      FOR rec_ IN Work_Center_API.Get_Production_Line_Rec (contract_,
                                                           part_no_) LOOP
         calendar_id_ := Production_Line_API.Get_Calendar_Id(contract_, rec_.production_line);
         -- Check to see if the due date is in the Manufacturing Line's calendar.
         -- If not, get previous calendar day.
         -- If no previous day exists in the line's calendar, raise error.
         IF ( Work_Time_Calendar_API.Is_Working_Day(calendar_id_, due_date_) = 0 ) THEN
            local_due_date_ := Work_Time_Calendar_API.Get_Previous_Work_Day (calendar_id_, due_date_);
            IF local_due_date_ IS NULL THEN
               Error_SYS.Record_General(lu_name_, 'NO_PREV_DAY: Due date is not in Production Line calendar.');
            END IF;
         ELSE
            local_due_date_ := due_date_;
         END IF;
         horizon_id_ := Production_Line_Part_API.Get_Horizon_Id (contract_,
                                                                 part_no_,
                                                                 rec_.production_line);
         -- Get scheduled fraction
         sched_frac_ := Production_Line_Part_API.Get_Schedule_Fraction_Db(contract_,
                                                                          part_no_,
                                                                          rec_.production_line );
         -- If fraction allowed do not round, otherwise round to integer.
         IF (sched_frac_ = 'Fraction Not Allowed') THEN
            qty_scheduled_ := round(qty_due_ * (rec_.schedule_percentage / 100),0);
         ELSIF (sched_frac_ = 'Fraction Qty Allowed') THEN
            qty_scheduled_ := qty_due_ * (rec_.schedule_percentage / 100);
         ELSE
            qty_scheduled_ := qty_due_ * (rec_.schedule_percentage / 100);
         END IF;
         --
         prod_line_location_ := Production_Line_API.Get_Production_Line_Location(contract_,
                                                                                 part_no_,
                                                                                 rec_.production_line);
         IF (Schedule_Horizon_API.Is_Date_Firm( contract_,
                                                horizon_id_,
                                                local_due_date_,
                                                rec_.production_line ) = 1) THEN
            IF (Schedule_Horizon_API.Get_Roll_Firm_Sched(horizon_id_) =
                Roll_Firm_Sched_API.DECODE('ROLL')) THEN
               local_due_date_ := Schedule_Horizon_API.Get_First_Avail_Sched_Date( contract_,
                                                                                   horizon_id_,
                                                                                   rec_.production_line );
               $IF Component_Prosch_SYS.INSTALLED $THEN
                  Line_Sched_Receipt_API.Create_Line_Sched_Receipt (
                              line_sched_receipt_id_ => line_sched_receipt_id_,
                              contract_              => contract_,
                              part_no_               => part_no_,
                              production_line_       => rec_.production_line,
                              schedule_date_         => local_due_date_,
                              qty_scheduled_         => qty_scheduled_,
                              proposed_location_     => prod_line_location_,
                              demand_source_         => 'MS',
                              proposed_sequence_     => Line_Sched_Receipt_API.Get_Next_Build_Seq(contract_, part_no_, rec_.production_line, local_due_date_));
               $END
               
               $IF (Component_Crp_SYS.INSTALLED) $THEN
                  Routing_List_API.Get_Build_Plan_Alternative(routing_revision_no_, routing_alternative_no_, contract_, part_no_,
                                                               Shop_Ord_Code_API.Decode('M'), due_date_, qty_scheduled_ );
   
                  IF (start_crp_calc_ AND routing_revision_no_ IS NOT NULL ) THEN
                     Crp_Mach_Operation_Util_API.Process_Crp(contract_        => contract_,
                                                             part_no_         => part_no_,
                                                             due_date_        => due_date_,
                                                             due_counter_     => Work_Time_Calendar_API.Get_Work_Day_Counter (manuf_calendar_, due_date_),
                                                             crp_source_db_   => Mach_Op_Load_Source_API.DB_PRODUCTION_SCHEDULE,
                                                             bom_type_db_     => 'M',
                                                             rev_qty_due_     => qty_scheduled_,
                                                             activity_seq_    => NULL,
                                                             calendar_id_     => manuf_calendar_,
                                                             order_ref1_      => line_sched_receipt_id_,
                                                             order_ref2_      => '*',
                                                             routing_rev_     => routing_revision_no_,
                                                             routing_alt_     => routing_alternative_no_,
                                                             start_date_      => NULL);
                  END IF;
               $END
   
               Supply_Order_Detail_API.Batch_New__ (
                  contract_           => contract_,
                  part_no_            => part_no_,
                  png_                => png_,
                  ms_set_             => ms_set_,
                  ms_date_            => due_date_,
                  line_no_            => line_no_,
                  activity_seq_       => 0,
                  supply_order_type_  => 'S',
                  supply_order_seq_   => NULL,
                  supply_order_no_    => line_sched_receipt_id_,
                  supply_release_no_  => NULL,
                  supply_sequence_no_ => NULL,
                  order_qty_          => qty_scheduled_ );
               
               Pegged_Supply_Demand_Util_API.Insert_Line_Sched_Receipt__(contract_,
                                                                         part_no_,
                                                                         png_,
                                                                         ms_set_,
                                                                         line_sched_receipt_id_);
            END IF; -- If no roll then ignore requirement
         ELSE -- Not firm, create schedule receipt
            $IF Component_Prosch_SYS.INSTALLED $THEN
               Line_Sched_Receipt_API.Create_Line_Sched_Receipt (
                           line_sched_receipt_id_ => line_sched_receipt_id_,
                           contract_              => contract_,
                           part_no_               => part_no_,
                           production_line_       => rec_.production_line,
                           schedule_date_         => local_due_date_,
                           qty_scheduled_         => qty_scheduled_,
                           proposed_location_     => prod_line_location_,
                           demand_source_         => 'MS',
                           proposed_sequence_     => Line_Sched_Receipt_API.Get_Next_Build_Seq(contract_, part_no_, rec_.production_line, local_due_date_));
            $END
            
            $IF (Component_Crp_SYS.INSTALLED) $THEN
               Routing_List_API.Get_Build_Plan_Alternative(routing_revision_no_, routing_alternative_no_, contract_, part_no_,
                                                            Shop_Ord_Code_API.Decode('M'), due_date_, qty_scheduled_ );
   
               IF (start_crp_calc_ AND routing_revision_no_ IS NOT NULL ) THEN
                  Crp_Mach_Operation_Util_API.Process_Crp(contract_        => contract_,
                                                          part_no_         => part_no_,
                                                          due_date_        => due_date_,
                                                          due_counter_     => Work_Time_Calendar_API.Get_Work_Day_Counter (manuf_calendar_, due_date_),
                                                          crp_source_db_   => Mach_Op_Load_Source_API.DB_MASTER_SCHEDULE,
                                                          bom_type_db_     => 'M',
                                                          rev_qty_due_     => qty_scheduled_,
                                                          activity_seq_    => NULL,
                                                          calendar_id_     => manuf_calendar_,
                                                          order_ref1_      => line_sched_receipt_id_,
                                                          order_ref2_      => '*',
                                                          routing_rev_     => routing_revision_no_,
                                                          routing_alt_     => routing_alternative_no_,
                                                          start_date_      => NULL);
               END IF;
            $END
   
            Supply_Order_Detail_API.Batch_New__ (
               contract_           => contract_,
               part_no_            => part_no_,
               png_                => png_,
               ms_set_             => ms_set_,
               ms_date_            => due_date_,
               line_no_            => line_no_,
               activity_seq_       => 0,
               supply_order_type_  => 'S',
               supply_order_seq_   => NULL,
               supply_order_no_    => line_sched_receipt_id_,
               supply_release_no_  => NULL,
               supply_sequence_no_ => NULL,
               order_qty_          => qty_scheduled_ );
         END IF;
      END LOOP;
   END Core;

BEGIN
   Core(contract_, part_no_, png_, ms_set_, line_no_, due_date_, manuf_calendar_, qty_due_, start_crp_calc_);
END Create_Line_Sched_Receipts___;


PROCEDURE Generate_Supply___(
   applied_dis_ord_date_          OUT    DATE,
   adjusted_increment_qty_        IN OUT NOCOPY NUMBER,
   do_supply_arr_                 IN OUT NOCOPY Supply_Collection,
   contract_                      IN     VARCHAR2,
   part_no_                       IN     VARCHAR2,
   png_                           IN     VARCHAR2,
   ms_set_                        IN     NUMBER,
   split_manuf_acquired_          IN     VARCHAR2,
   demand_tf_                     IN     DATE,
   planning_tf_                   IN     DATE,
   calendar_id_                   IN     VARCHAR2,
   unit_meas_                     IN     VARCHAR2,
   is_part_internally_sourced_    IN     VARCHAR2,
   manuf_supply_type_             IN     VARCHAR2,
   pur_lu_req_exists_             IN     BOOLEAN,
   ms_date_                       IN     DATE,
   acquired_supply_type_          IN     VARCHAR2,
   stock_management_              IN     VARCHAR2,
   lead_time_code_db_             IN     VARCHAR2,
   order_requisition_             IN     VARCHAR2,
   start_crp_calc_                IN     BOOLEAN)
IS
   
   PROCEDURE Core(
      applied_dis_ord_date_          OUT    DATE,
      adjusted_increment_qty_        IN OUT NOCOPY NUMBER,
      do_supply_arr_                 IN OUT NOCOPY Supply_Collection,
      contract_                      IN     VARCHAR2,
      part_no_                       IN     VARCHAR2,
      png_                           IN     VARCHAR2,
      ms_set_                        IN     NUMBER,
      split_manuf_acquired_          IN     VARCHAR2,
      demand_tf_                     IN     DATE,
      planning_tf_                   IN     DATE,
      calendar_id_                   IN     VARCHAR2,
      unit_meas_                     IN     VARCHAR2,
      is_part_internally_sourced_    IN     VARCHAR2,
      manuf_supply_type_             IN     VARCHAR2,
      pur_lu_req_exists_             IN     BOOLEAN,
      ms_date_                       IN     DATE,
      acquired_supply_type_          IN     VARCHAR2,
      stock_management_              IN     VARCHAR2,
      lead_time_code_db_             IN     VARCHAR2,
      order_requisition_             IN     VARCHAR2,
      start_crp_calc_                IN     BOOLEAN)
   IS
   
   BEGIN
      -- Distribution Order(s) are created first, same as in MRP
      IF (is_part_internally_sourced_ = 'TRUE') THEN
         $IF Component_Disord_SYS.INSTALLED $THEN
            Generate_Do__ (
               applied_dis_ord_date_,
               adjusted_increment_qty_,
               do_supply_arr_,
               contract_,
               part_no_,
               png_,
               ms_set_,
               split_manuf_acquired_,
               demand_tf_,
               planning_tf_,
               calendar_id_);
         $ELSE
            NULL;
         $END
      END IF;
   
      IF (split_manuf_acquired_ = 'SPLIT') THEN
         IF (manuf_supply_type_ IN ('R','O')) THEN
            Generate_Shop_Proposal__ (
               contract_,
               part_no_,
               png_,
               0, -- activity_seq
               split_manuf_acquired_,
               demand_tf_,
               planning_tf_,
               calendar_id_,
               start_crp_calc_,
               do_supply_arr_);
         ELSIF (manuf_supply_type_ = 'S') THEN
            $IF Component_Prosch_SYS.INSTALLED $THEN
               Gen_Production_Schedules__ (
                  contract_,
                  part_no_,
                  png_,
                  ms_set_,
                  split_manuf_acquired_,
                  demand_tf_,
                  planning_tf_,
                  ms_date_,
                  calendar_id_,
                  start_crp_calc_,
                  do_supply_arr_);
            $ELSE
               NULL;
            $END
         END IF;
   
         IF (acquired_supply_type_ IN ('R','O') AND pur_lu_req_exists_) THEN
            IF (stock_management_ = 'SYSTEM MANAGED INVENTORY') THEN
               Generate_Pur_Req__ (
                  contract_,
                  part_no_,
                  png_,
                  0, -- activity_seq
                  unit_meas_,
                  demand_tf_,
                  planning_tf_);
            END IF;
         ELSIF ((acquired_supply_type_ = 'S') AND (stock_management_ = 'SYSTEM MANAGED INVENTORY')) THEN
            Generate_Supply_Schedules___(contract_, part_no_, png_, ms_set_, demand_tf_, planning_tf_);
         END IF;
      ELSE
         IF (lead_time_code_db_ = 'M' AND order_requisition_ IN ('R', 'O')) THEN
   
            Generate_Shop_Proposal__ (
               contract_,
               part_no_,
               png_,
               0, -- activity_seq
               split_manuf_acquired_,
               demand_tf_,
               planning_tf_,
               calendar_id_,
               start_crp_calc_,
               do_supply_arr_);
   
         ELSIF (lead_time_code_db_ = 'P' AND
                (order_requisition_ IN ('R', 'O')) AND pur_lu_req_exists_) THEN
            IF (stock_management_ = 'SYSTEM MANAGED INVENTORY') THEN
   
               Generate_Pur_Req__ (
                  contract_,
                  part_no_,
                  png_,
                  0, -- activity_seq
                  unit_meas_,
                  demand_tf_,
                  planning_tf_);
            END IF;
         ELSIF (lead_time_code_db_ = 'M' AND order_requisition_ = 'S') THEN
   
            $IF Component_Prosch_SYS.INSTALLED $THEN
               Gen_Production_Schedules__ (
                  contract_,
                  part_no_,
                  png_,
                  ms_set_,
                  split_manuf_acquired_,
                  demand_tf_,
                  planning_tf_,
                  ms_date_,
                  calendar_id_,
                  start_crp_calc_,
                  do_supply_arr_);
            $ELSE
               NULL;
            $END
         ELSIF (lead_time_code_db_ = 'P' AND (order_requisition_ = 'S') AND
               (stock_management_ = 'SYSTEM MANAGED INVENTORY')) THEN
            Generate_Supply_Schedules___(contract_, part_no_, png_, ms_set_, demand_tf_, planning_tf_);
         END IF;
      END IF;
   END Core;

BEGIN
   Core(applied_dis_ord_date_, adjusted_increment_qty_, do_supply_arr_, contract_, part_no_, png_, ms_set_, split_manuf_acquired_, demand_tf_, planning_tf_, calendar_id_, unit_meas_, is_part_internally_sourced_, manuf_supply_type_, pur_lu_req_exists_, ms_date_, acquired_supply_type_, stock_management_, lead_time_code_db_, order_requisition_, start_crp_calc_);
END Generate_Supply___;


PROCEDURE Generate_Supply_Schedules___(
   contract_    IN VARCHAR2,
   part_no_     IN VARCHAR2,
   png_         IN VARCHAR2,
   ms_set_      IN NUMBER,
   demand_tf_   IN DATE,
   planning_tf_ IN DATE )
IS
   
   PROCEDURE Core(
      contract_    IN VARCHAR2,
      part_no_     IN VARCHAR2,
      png_         IN VARCHAR2,
      ms_set_      IN NUMBER,
      demand_tf_   IN DATE,
      planning_tf_ IN DATE )
   IS
      min_ms_date_   DATE;
      max_ms_date_   DATE;
   
      CURSOR get_min_max_dates IS
         SELECT MIN(ms_date), MAX(ms_date)
         FROM   ms_receipt_tab
         WHERE  contract = contract_
         AND    part_no  = part_no_
         AND    png      = png_
         AND    ms_set   = ms_set_
         AND    ms_date BETWEEN demand_tf_ AND planning_tf_
         AND    master_sched_rcpt > 0;
   BEGIN
   
      OPEN  get_min_max_dates;
      FETCH get_min_max_dates INTO min_ms_date_, max_ms_date_;
      
      IF min_ms_date_ IS NOT NULL THEN
         $IF Component_Supsch_SYS.INSTALLED $THEN
            Supplier_Scheduler_API.Create_Schedules_From_Ms (contract_, part_no_, ms_set_, demand_tf_, planning_tf_, min_ms_date_, max_ms_date_);
         $ELSE
            NULL;
         $END
      END IF;
      CLOSE get_min_max_dates;
   END Core;

BEGIN
   Core(contract_, part_no_, png_, ms_set_, demand_tf_, planning_tf_);
END Generate_Supply_Schedules___;


PROCEDURE Remove_Supply_Schedules___ (
   contract_    IN VARCHAR2,
   part_no_     IN VARCHAR2,
   png_         IN VARCHAR2,
   demand_tf_   IN DATE,
   planning_tf_ IN DATE )
IS
   
   PROCEDURE Core (
      contract_    IN VARCHAR2,
      part_no_     IN VARCHAR2,
      png_         IN VARCHAR2,
      demand_tf_   IN DATE,
      planning_tf_ IN DATE )
   IS
      parent_date_       DATE;
      parent_line_no_    NUMBER;
   
      CURSOR get_sub_orders IS
         SELECT activity_seq, ms_date, line_no, sysgen_flag
         FROM   ms_receipt_tab
         WHERE  contract = contract_
         AND    part_no  = part_no_
         AND    png      = png_
         AND    ms_set   = 1
         AND    ms_date >= demand_tf_
         AND    NVL(master_sched_rcpt, 0) > 0;
   
      CURSOR get_sup_order_details IS
         SELECT supply_order_no,
                supply_order_seq
         FROM   supply_order_detail_tab
         WHERE  contract           = contract_
         AND    part_no            = part_no_
         AND    png                = png_
         AND    ms_set             = 1
         AND    ms_date            = parent_date_
         AND    line_no            = parent_line_no_
         AND    supply_order_type  = 'SS'
         AND    order_created      = 'FALSE';
   BEGIN
   
      FOR sub_order_rec_ IN get_sub_orders LOOP
         parent_date_    := sub_order_rec_.ms_date;
         parent_line_no_ := sub_order_rec_.line_no;
   
         FOR sup_detail_rec_ IN get_sup_order_details LOOP
            IF ((sub_order_rec_.ms_date >= demand_tf_ AND sub_order_rec_.ms_date <= planning_tf_) OR (sub_order_rec_.ms_date > planning_tf_ AND sub_order_rec_.sysgen_flag = 'N')) THEN
               Supply_Order_Detail_API.Batch_Remove__ (
                  contract_          => contract_,
                  part_no_           => part_no_,
                  png_               => png_,
                  ms_set_            => 1,
                  activity_seq_      => sub_order_rec_.activity_seq,
                  ms_date_           => sub_order_rec_.ms_date,
                  line_no_           => sub_order_rec_.line_no,
                  supply_order_type_ => 'SS',
                  supply_order_seq_  => sup_detail_rec_.supply_order_seq );
            END IF;
         END LOOP;
      END LOOP;
   END Core;

BEGIN
   Core(contract_, part_no_, png_, demand_tf_, planning_tf_);
END Remove_Supply_Schedules___;


PROCEDURE Check_For_Zero_Rate___ (
   mps_arr_                     IN OUT NOCOPY Mps_Array_,
   records_deleted_cnt_         IN OUT NOCOPY PLS_INTEGER,
   current_index_               IN PLS_INTEGER,
   contract_                    IN VARCHAR2,
   part_no_                     IN VARCHAR2,
   png_                         IN VARCHAR2 )
IS
   
   PROCEDURE Core (
      mps_arr_                     IN OUT NOCOPY Mps_Array_,
      records_deleted_cnt_         IN OUT NOCOPY PLS_INTEGER,
      current_index_               IN PLS_INTEGER,
      contract_                    IN VARCHAR2,
      part_no_                     IN VARCHAR2,
      png_                         IN VARCHAR2 )
   IS
      org_mps_arr_      Mps_Array_ := mps_arr_;
      new_mps_arr_      Mps_Array_;
      index_            PLS_INTEGER := current_index_;
      dummy_            NUMBER;
      records_deleted_  BOOLEAN := FALSE;
      i_                PLS_INTEGER;
      cnt_              PLS_INTEGER := 1;
      
      CURSOR check_zero_rate (ms_date_ DATE) IS
         SELECT 1
         FROM MS_QTY_RATE_BY_PERIOD_TAB
         WHERE contract = contract_
         AND   part_no  = part_no_
         AND   png      = png_
         AND   ms_date_ BETWEEN from_date AND to_date
         AND   rate = 0;
   BEGIN
      Trace_Sys.Message ('Start');
      LOOP 
         EXIT WHEN index_ < mps_arr_.FIRST;
         OPEN check_zero_rate(mps_arr_(index_).work_day);
         FETCH check_zero_rate INTO dummy_;
         EXIT WHEN check_zero_rate%NOTFOUND;
         CLOSE check_zero_rate;
         -- Trace_SYS.Message('*** index_='|| index_ ||' ms_date = '||mps_arr_(index_).work_day);
         
         IF index_ = mps_arr_.FIRST AND index_ = mps_arr_.LAST THEN
            -- only one record outside PTF => the MPS will be placed on the original date
            mps_arr_ := org_mps_arr_;
            records_deleted_cnt_ := 0;
            EXIT;
         ELSIF index_ = mps_arr_.FIRST THEN
            -- Push MPS forward
            -- This happens if zero rate is crossing PTF
            mps_arr_(index_+1).demand := mps_arr_(index_).demand + mps_arr_(index_+1).demand;
            mps_arr_(index_+1).act_receipt := mps_arr_(index_).act_receipt + mps_arr_(index_+1).act_receipt;
            mps_arr_(index_+1).mps := mps_arr_(index_).mps + mps_arr_(index_+1).mps;
            mps_arr_.DELETE(index_);
            records_deleted_ := TRUE;
            records_deleted_cnt_ := records_deleted_cnt_ + 1;
            EXIT;
         END IF;
         
         index_ := index_ - 1;
         EXIT WHEN index_ < mps_arr_.FIRST;
         -- The normal case is to move MPS to an earlier date prior the zero rate period
         mps_arr_(index_).demand := mps_arr_(index_).demand + mps_arr_(index_+1).demand;
         mps_arr_(index_).act_receipt := mps_arr_(index_).act_receipt + mps_arr_(index_+1).act_receipt;
         mps_arr_(index_).mps := mps_arr_(index_).mps + mps_arr_(index_+1).mps;
         mps_arr_.DELETE(index_+1);
         records_deleted_ := TRUE;
         records_deleted_cnt_ := records_deleted_cnt_ + 1;
      END LOOP;
      
      IF check_zero_rate%ISOPEN THEN
         CLOSE check_zero_rate;
      END IF;
         
      IF records_deleted_ THEN
         i_ := mps_arr_.FIRST;
         WHILE (i_ IS NOT NULL) LOOP
            IF mps_arr_.EXISTS(i_) THEN
               new_mps_arr_(cnt_) := mps_arr_(i_);
               cnt_ := cnt_ + 1;
            END IF;
            i_ := mps_arr_.NEXT(i_);
         END LOOP;
         mps_arr_ := new_mps_arr_;
      END IF;   
      Trace_Sys.Message ('End');
   END Core;

BEGIN
   Core(mps_arr_, records_deleted_cnt_, current_index_, contract_, part_no_, png_);
END Check_For_Zero_Rate___;


PROCEDURE Lot_Size_And_Create_New_Mps___ (
   mps_arr_                     IN OUT NOCOPY Mps_Array_,
   current_index_               IN PLS_INTEGER,
   new_mps_                     IN NUMBER,
   contract_                    IN VARCHAR2,
   part_no_                     IN VARCHAR2,
   png_                         IN VARCHAR2,
   ms_set_                      IN VARCHAR2,
   ptf_date_                    IN DATE,
   calendar_id_                 IN VARCHAR2,
   inventory_part_plan_rec_     IN Inventory_Part_Planning_API.Public_Rec,
   start_crp_calc_              IN BOOLEAN,
   shop_order_proposal_flag_db_ IN VARCHAR2,
   lead_time_code_db_           IN VARCHAR2 )
IS
   
   PROCEDURE Core (
      mps_arr_                     IN OUT NOCOPY Mps_Array_,
      current_index_               IN PLS_INTEGER,
      new_mps_                     IN NUMBER,
      contract_                    IN VARCHAR2,
      part_no_                     IN VARCHAR2,
      png_                         IN VARCHAR2,
      ms_set_                      IN VARCHAR2,
      ptf_date_                    IN DATE,
      calendar_id_                 IN VARCHAR2,
      inventory_part_plan_rec_     IN Inventory_Part_Planning_API.Public_Rec,
      start_crp_calc_              IN BOOLEAN,
      shop_order_proposal_flag_db_ IN VARCHAR2,
      lead_time_code_db_           IN VARCHAR2 )
   IS
      local_index_           PLS_INTEGER;
      local_mps_             NUMBER := new_mps_;
      order_gap_time_        NUMBER;
      ptf_crossed_           EXCEPTION;
      local_contract_        VARCHAR2(200);
      no_of_orders_          PLS_INTEGER := 0;
      used_required_counter_ NUMBER;
      used_required_date_    DATE;
      max_order_qty_         NUMBER;
      qty_to_plan_           NUMBER;
      from_date_             DATE;
      rate_                  NUMBER := 0;
      unit_                  VARCHAR2(5);
      u_day_                 VARCHAR2(3):= Ms_Rate_Period_Unit_API.Get_Db_Value(0);
      u_week_                VARCHAR2(4):= Ms_Rate_Period_Unit_API.Get_Db_Value(1);
      first_iteration_       BOOLEAN := FALSE;  
      week_start_            DATE;
      mps_on_date_           NUMBER := 0;
      infinite_capacity_     BOOLEAN := FALSE;
      prev_unit_             VARCHAR2(5);
      period_end_date_       DATE;
      ms_receipt_            NUMBER := 0;
      line_no_               NUMBER;
      inv_max_ord_qty_       NUMBER := 0;
      mps_size_              NUMBER := 0;
      mps_on_orig_date_      NUMBER := 0;
      min_max_mps_           NUMBER := 0;
      ms_receipt_total_      NUMBER;
      lot_rules_considered_  BOOLEAN := FALSE;
      count_                 PLS_INTEGER := 0;
      max_per_day_           NUMBER;
      
      CURSOR get_ms_receipt_by_week (ms_date_ DATE) IS
         SELECT NVL(SUM(master_sched_rcpt), 0)
         FROM LEVEL_1_FORECAST_TAB
         WHERE contract    = contract_
         AND   part_no     = part_no_
         AND   png         = png_
         AND   ms_set      = ms_set_
         AND   ms_date BETWEEN ms_date_ AND (ms_date_ + 6)
         AND   NVL(master_sched_rcpt, 0) > 0;
         
      CURSOR get_ms_receipt (ms_date_ DATE) IS
         SELECT NVL(master_sched_rcpt,0)
         FROM LEVEL_1_FORECAST_TAB
         WHERE contract    = contract_
         AND   part_no     = part_no_
         AND   png         = png_
         AND   ms_set      = ms_set_
         AND   ms_date     = ms_date_
         AND   sysgen_flag = sysgen_yes_
         AND   NVL(master_sched_rcpt, 0) > 0;
      
      CURSOR get_receipt (ms_date_ DATE) IS
         SELECT line_no
         FROM MS_RECEIPT_TAB
         WHERE contract    = contract_
         AND   part_no     = part_no_
         AND   png         = png_
         AND   ms_set      = ms_set_
         AND   ms_date     = ms_date_
         AND   sysgen_flag = sysgen_yes_
         AND   NVL(master_sched_rcpt, 0) > 0;
      
   BEGIN
   
      IF (inventory_part_plan_rec_.max_order_qty > 0 OR inventory_part_plan_rec_.min_order_qty > 0 OR inventory_part_plan_rec_.mul_order_qty > 0 OR
          lead_time_code_db_ = 'M' OR inventory_part_plan_rec_.split_manuf_acquired = 'SPLIT')THEN
         lot_rules_considered_ := TRUE;
      END IF;
   
      --check if a rate > 0 is specified
      Ms_Qty_Rate_By_Period_API.Get_Period_Info(from_date_, rate_, unit_, contract_, part_no_, png_, mps_arr_(current_index_).work_day);
      -- Start applying Min rule
      IF rate_ IS NULL AND inventory_part_plan_rec_.min_order_qty != 0 AND inventory_part_plan_rec_.min_order_qty >= local_mps_ THEN
         local_mps_ := inventory_part_plan_rec_.min_order_qty;
      END IF;
      -- Continue with multiple order qty rule
      IF rate_ IS NULL AND inventory_part_plan_rec_.mul_order_qty != 0 AND local_mps_ > 0 THEN
         local_mps_ := inventory_part_plan_rec_.mul_order_qty * CEIL(local_mps_ / inventory_part_plan_rec_.mul_order_qty);
      END IF;
      
      IF (rate_ IS NULL AND inventory_part_plan_rec_.max_order_qty = 0) THEN
         max_order_qty_ := 99999999;
      ELSIF (rate_ > 0) THEN
         max_order_qty_ := rate_;
         lot_rules_considered_ := TRUE;
      ELSE
         max_order_qty_ := inventory_part_plan_rec_.max_order_qty;
      END IF;
      
      IF (lot_rules_considered_) THEN
         -- Check if max order qty rule should be used
         IF (local_mps_ <= max_order_qty_ AND rate_ IS NULL) THEN
            -- Don't use max order qty rule here
            Create_New_Mps___(mps_arr_, current_index_, local_mps_, contract_, part_no_, png_, ms_set_, ptf_date_, start_crp_calc_,
                              shop_order_proposal_flag_db_, calendar_id_);
         --Check if rate should be used
         ELSIF (rate_ > 0) THEN
            qty_to_plan_ := local_mps_;
            IF (inventory_part_plan_rec_.max_order_qty > 0) THEN
               inv_max_ord_qty_ := inventory_part_plan_rec_.max_order_qty;        
            END IF;
            first_iteration_ := TRUE;
            WHILE (qty_to_plan_ > 0) LOOP
               max_per_day_ := 0;
               ms_receipt_total_ := 0;
               IF first_iteration_ = TRUE THEN
                  used_required_date_ := mps_arr_(current_index_).work_day;
                  used_required_counter_ := mps_arr_(current_index_).counter;
                  IF (qty_to_plan_ >= max_order_qty_) THEN
                     mps_on_orig_date_ := max_order_qty_;
                  ELSE
                     mps_on_orig_date_ := qty_to_plan_;
                  END IF;
                  --Calculation of max quantity per day when inventory max order quantity and minimum order quantity both have values.
                  IF (inv_max_ord_qty_ > 0 AND inventory_part_plan_rec_.min_order_qty != 0) THEN
                     count_ := 0;
                     min_max_mps_ := rate_;
                     WHILE (min_max_mps_ >= inv_max_ord_qty_) LOOP
                        count_ := count_ + 1;                                                          
                        min_max_mps_ := min_max_mps_ - inv_max_ord_qty_;
                     END LOOP;
                     IF min_max_mps_ > 0 AND inventory_part_plan_rec_.min_order_qty > min_max_mps_ THEN 
                        IF (((count_ * inv_max_ord_qty_) + inventory_part_plan_rec_.min_order_qty) > rate_ ) THEN
                           max_order_qty_ := count_ * inv_max_ord_qty_;
                        END IF;
                     END IF;
                     IF (mps_on_orig_date_ > max_order_qty_) THEN
                        mps_on_orig_date_ := max_order_qty_;
                     END IF;
                  END IF;
                  IF unit_ = u_week_ THEN
                     -- Get latest Monday
                     week_start_ := TRUNC(used_required_date_, 'IW');
                     OPEN get_ms_receipt_by_week(week_start_);
                     FETCH get_ms_receipt_by_week INTO ms_receipt_total_;
                     CLOSE get_ms_receipt_by_week;
                     
                     IF max_order_qty_ < ms_receipt_total_ THEN
                        mps_on_orig_date_ := 0;
                     ELSIF mps_on_orig_date_ >= max_order_qty_ - ms_receipt_total_ THEN         
                        mps_on_orig_date_ := max_order_qty_ - ms_receipt_total_;
                     END IF;
                     
                  END IF;
               ELSIF rate_ > 0 THEN            
                  IF unit_ = u_day_ THEN              
                     local_index_ := Find_Local_Index_Forward___(mps_arr_, used_required_date_ - 1);
                     IF local_index_ = -1 OR (Work_Time_Calendar_API.Get_Previous_Work_Day(calendar_id_, used_required_date_) <= ptf_date_) THEN
                        Trace_SYS.Message('***Within ptf - unit is day***');
                        mps_on_date_ :=  mps_on_orig_date_+ qty_to_plan_;
                        used_required_date_ := mps_arr_(current_index_).work_day;
                        EXIT;
                     END IF;
                     used_required_counter_ := mps_arr_(local_index_).counter;
                     used_required_date_ := mps_arr_(local_index_).work_day;
                     Trace_SYS.Message('unit=day, required_date_ = '||used_required_date_||' from_date = '||from_date_);
                     IF qty_to_plan_ >= max_order_qty_ THEN
                        max_per_day_ := max_order_qty_;
                     ELSE
                        max_per_day_ := qty_to_plan_;
                     END IF;
                  ELSE              
                     local_index_ := Find_Local_Index_Forward___(mps_arr_, week_start_-7);
                     -- Trace_SYS.Message('Week start - 7 = '||to_char(week_start_-7));
                     IF local_index_ = -1 THEN 
                        mps_on_date_ :=  mps_on_orig_date_+ qty_to_plan_;
                        used_required_date_ := mps_arr_(current_index_).work_day;
                        EXIT;
                     ELSIF  Work_Time_Calendar_API.Get_Prior_Work_Day(calendar_id_,week_start_-7) <= ptf_date_ THEN
                        local_index_ := Find_Local_Index_Forward___(mps_arr_, ptf_date_ + 1);
                        used_required_date_ := mps_arr_(local_index_).work_day;
                        IF NOT Ms_Qty_Rate_By_Period_API.Check_If_Period_Exist(contract_, part_no_, png_, used_required_date_) THEN
                           infinite_capacity_ := TRUE;
                           mps_on_date_ := qty_to_plan_;
                        ELSE 
                           mps_on_date_ :=  mps_on_orig_date_+ qty_to_plan_;
                           used_required_date_ := mps_arr_(current_index_).work_day;
                        END IF;
                        EXIT;
                     END IF;
                     used_required_date_ := mps_arr_(local_index_).work_day;
                     week_start_ := week_start_-7; 
                     -- Trace_SYS.Message('A week start = '||to_char(week_start_)|| ' required_date_ = '||used_required_date_||' qty_to_plan_ '||qty_to_plan_||' from_date = '||from_date_);
                     max_per_day_ := Get_Available_Mps_For_Week___(contract_, part_no_, png_, ms_set_, used_required_date_, max_order_qty_, 
                                                                   mps_arr_(current_index_).work_day, qty_to_plan_, week_start_);
                     -- Trace_SYS.Message('A max_per_day_ = '||max_per_day_);
                     
                  END IF;
                  
                  IF (used_required_date_ < from_date_) THEN                            
                     rate_ := 0;
                     prev_unit_ := unit_;
                     Ms_Qty_Rate_By_Period_API.Get_Period_Info(from_date_, rate_, unit_, contract_, part_no_, png_, used_required_date_);
                     Trace_Sys.Message('period info = '||from_date_||'/'||rate_||'/'||unit_);
                     IF (rate_ > 0) THEN
                        max_order_qty_ := rate_;
                        IF (inv_max_ord_qty_ > 0 AND inventory_part_plan_rec_.min_order_qty != 0) THEN
                           count_ := 0;
                           min_max_mps_ := rate_;
                           WHILE (min_max_mps_ >= inv_max_ord_qty_) LOOP
                              count_ := count_ + 1;                                                          
                              min_max_mps_ := min_max_mps_ - inv_max_ord_qty_;
                           END LOOP;
                           IF min_max_mps_ > 0 AND inventory_part_plan_rec_.min_order_qty > min_max_mps_ THEN 
                              IF (((count_ * inv_max_ord_qty_) + inventory_part_plan_rec_.min_order_qty) > rate_ ) THEN
                                 max_order_qty_ := count_ * inv_max_ord_qty_;
                              END IF;
                           END IF;
                        END IF;
                        IF unit_ = u_day_ THEN
                           IF (prev_unit_ = u_week_) THEN
                              period_end_date_ := Ms_Qty_Rate_By_Period_API.Get_Period_End_Date(contract_, part_no_, png_, from_date_);
                              local_index_ := Find_Local_Index_Forward___(mps_arr_, period_end_date_);
                              used_required_date_ := mps_arr_(local_index_).work_day;
                              used_required_counter_ := mps_arr_(local_index_).counter;
                           END IF;
                        ELSE 
                           IF (prev_unit_ = u_day_) THEN
                              -- Get latest Monday
                              week_start_ := TRUNC(used_required_date_, 'IW');
                              local_index_ := Find_Local_Index_Backward___(mps_arr_, week_start_);
                              used_required_date_ := mps_arr_(local_index_).work_day;
                           END IF; 
                           -- Trace_SYS.Message('week start = '||to_char(week_start_)|| ' required_date_ = '||used_required_date_||' qty_to_plan_ '||qty_to_plan_||' from_date = '||from_date_);
                           max_per_day_ := Get_Available_Mps_For_Week___(contract_, part_no_, png_, ms_set_, used_required_date_, max_order_qty_, 
                                                                         mps_arr_(current_index_).work_day, qty_to_plan_, week_start_);
                           -- Trace_SYS.Message('max_per_day_ = '||max_per_day_);
                        END IF;
                     ELSE
                        IF (prev_unit_ = u_week_ AND from_date_ IS NOT NULL) THEN                   
                           used_required_date_ := Work_Time_Calendar_API.Get_Closest_Work_Day(calendar_id_, from_date_); 
                           max_per_day_ := Get_Available_Mps_For_Week___(contract_, part_no_, png_, ms_set_, used_required_date_, max_order_qty_, 
                                                                         mps_arr_(current_index_).work_day, qty_to_plan_);                     
                           IF (used_required_date_ = week_start_+7 OR used_required_date_ = mps_arr_(current_index_).work_day) THEN 
                              used_required_date_ := Work_Time_Calendar_API.Get_Previous_Work_Day(calendar_id_, from_date_);
                              infinite_capacity_ := TRUE;
                              mps_on_date_ := qty_to_plan_;
                              EXIT;
                           END IF;
                        ELSE
                           infinite_capacity_ := TRUE;
                           mps_on_date_ := qty_to_plan_;
                           EXIT;
                        END IF;  
                     END IF;   
                  END IF;
               ELSE
                  -- Trace_Sys.Message('1 used_required_date_ = '||used_required_date_);
                  used_required_date_ := Work_Time_Calendar_API.Get_Previous_Work_Day(calendar_id_, used_required_date_);
                  -- Trace_Sys.Message('2 used_required_date_ = '||used_required_date_);
                  infinite_capacity_ := TRUE;
                  mps_on_date_ := qty_to_plan_;
                  EXIT;
               END IF;
               Trace_Sys.Message('3 used_required_date_ = '||used_required_date_);
               local_index_ := Find_Local_Index___(mps_arr_, used_required_date_);
               IF local_index_ = -1 THEN
                  Error_Sys.Appl_General(lu_name_, 'INVALIDREQDATE: System cannot proceed with MPS generation for used required date :P1.', used_required_date_);
               END IF; 
            
               ms_receipt_ := 0;               
               OPEN get_ms_receipt(used_required_date_);
               FETCH get_ms_receipt INTO ms_receipt_;
               CLOSE get_ms_receipt;   
               IF (ms_receipt_ >= max_order_qty_) THEN         
                  CONTINUE;
               ELSIF ms_receipt_ > 0 AND unit_ = u_week_ AND max_per_day_ > 0 THEN
                  max_per_day_ := max_per_day_ + ms_receipt_;
               END IF;
            
               IF first_iteration_ = FALSE THEN
                  IF qty_to_plan_ >= max_order_qty_ THEN
                     IF (ms_receipt_ > 0 AND max_per_day_ > 0 ) THEN
                        OPEN get_receipt(used_required_date_);
                        FETCH get_receipt INTO line_no_;
                        CLOSE get_receipt;  
                        Ms_Receipt_API.Batch_Remove__(
                                          contract_,
                                          part_no_,
                                          png_,
                                          ms_set_,
                                          used_required_date_,
                                          line_no_);               
                        line_no_ := 0;
                        Level_1_Forecast_API.Batch_Modify__ (
                           contract_            => contract_,
                           part_no_             => part_no_,
                           png_                 => png_,
                           ms_set_              => ms_set_,
                           activity_seq_        => 0,
                           ms_date_             => used_required_date_,
                           parent_contract_     => NULL,
                           parent_part_         => NULL,
                           forecast_lev0_       => NULL,
                           forecast_lev1_       => NULL,
                           consumed_forecast_   => NULL,
                           actual_demand_       => NULL,
                           planned_demand_      => NULL,
                           supply_              => NULL,
                           consumed_supply_     => NULL,
                           firm_orders_         => NULL,
                           sched_orders_        => NULL,
                           rel_ord_rcpt_        => NULL,
                           master_sched_rcpt_   => 0,
                           avail_to_prom_       => NULL,
                           roll_up_rcpt_        => NULL,
                           net_avail_           => NULL,
                           proj_avail_          => NULL,
                           mtr_demand_qty_      => NULL,
                           mtr_supply_qty_      => NULL,
                           offset_              => NULL,
                           roll_flag_db_        => NULL,
                           sysgen_flag_         => NULL,
                           master_sched_status_ => NULL,
                           method_              => 'UPDATE' );
   
                        FOR i IN local_index_ .. mps_arr_.LAST LOOP
                           mps_arr_(i).projected_onhand := mps_arr_(i).projected_onhand - ms_receipt_;
                        END LOOP;
                     END IF;
                     IF (max_per_day_ > 0 AND (inv_max_ord_qty_ = 0 OR (inv_max_ord_qty_ > rate_ AND rate_ > 0))) THEN                 
                        Create_New_Mps___(mps_arr_, local_index_, max_per_day_, contract_, part_no_, png_, ms_set_, ptf_date_, start_crp_calc_,
                                          shop_order_proposal_flag_db_, calendar_id_);                 
                     ELSIF max_per_day_ > 0 THEN                                 
                        mps_size_ := max_per_day_;
                        count_ := 0;
                        WHILE (mps_size_ >= inv_max_ord_qty_) LOOP
                           count_ := count_ + 1;
                           Create_New_Mps___(mps_arr_, local_index_, inv_max_ord_qty_, contract_, part_no_, png_, ms_set_, ptf_date_, start_crp_calc_,
                                             shop_order_proposal_flag_db_, calendar_id_);                                      
                           mps_size_ := mps_size_ - inv_max_ord_qty_;
                        END LOOP;
                        IF (mps_size_ > 0) THEN
                           IF inventory_part_plan_rec_.min_order_qty != 0 AND inventory_part_plan_rec_.min_order_qty > mps_size_ THEN                     
                              IF count_ > 0 THEN
                                 IF (((count_ * inv_max_ord_qty_) + inventory_part_plan_rec_.min_order_qty)<= max_order_qty_ ) THEN
                                    mps_size_ := inventory_part_plan_rec_.min_order_qty;
                                 ELSE
                                    qty_to_plan_ := qty_to_plan_ - (max_per_day_ - mps_size_ - ms_receipt_);
                                    CONTINUE; 
                                 END IF;   
                              ELSE
                                 mps_size_ := inventory_part_plan_rec_.min_order_qty;
                              END IF;
                           END IF;
                           Create_New_Mps___(mps_arr_, local_index_, mps_size_, contract_, part_no_, png_, ms_set_, ptf_date_, start_crp_calc_,
                                             shop_order_proposal_flag_db_, calendar_id_);
                        END IF;
                     END IF;
                     qty_to_plan_ := qty_to_plan_ - (max_per_day_ - ms_receipt_);
                  ELSE
                     IF (ms_receipt_ > 0 AND max_per_day_ > 0) THEN 
                        IF unit_ = u_day_ THEN 
                           IF max_per_day_ > max_order_qty_ - ms_receipt_ THEN
                              max_per_day_ := max_order_qty_;
                           ELSE
                              max_per_day_ := max_per_day_ + ms_receipt_;
                           END IF;
                        END IF;
                        OPEN get_receipt(used_required_date_);
                        FETCH get_receipt INTO line_no_;
                        CLOSE get_receipt;  
                        Ms_Receipt_API.Batch_Remove__(
                                          contract_,
                                          part_no_,
                                          png_,
                                          ms_set_,
                                          used_required_date_,
                                          line_no_);               
                        line_no_ := 0;
                        Level_1_Forecast_API.Batch_Modify__ (
                           contract_            => contract_,
                           part_no_             => part_no_,
                           png_                 => png_,
                           ms_set_              => ms_set_,
                           activity_seq_        => 0,
                           ms_date_             => used_required_date_,
                           parent_contract_     => NULL,
                           parent_part_         => NULL,
                           forecast_lev0_       => NULL,
                           forecast_lev1_       => NULL,
                           consumed_forecast_   => NULL,
                           actual_demand_       => NULL,
                           planned_demand_      => NULL,
                           supply_              => NULL,
                           consumed_supply_     => NULL,
                           firm_orders_         => NULL,
                           sched_orders_        => NULL,
                           rel_ord_rcpt_        => NULL,
                           master_sched_rcpt_   => 0,
                           avail_to_prom_       => NULL,
                           roll_up_rcpt_        => NULL,
                           net_avail_           => NULL,
                           proj_avail_          => NULL,
                           mtr_demand_qty_      => NULL,
                           mtr_supply_qty_      => NULL,
                           offset_              => NULL,
                           roll_flag_db_        => NULL,
                           sysgen_flag_         => NULL,
                           master_sched_status_ => NULL,
                           method_              => 'UPDATE' );  
   
                        FOR i IN local_index_ .. mps_arr_.LAST LOOP
                           mps_arr_(i).projected_onhand := mps_arr_(i).projected_onhand - ms_receipt_;
                        END LOOP;
                     
                        qty_to_plan_ := qty_to_plan_ - (max_per_day_ - ms_receipt_);  
                     ELSE
                        qty_to_plan_ := qty_to_plan_ - max_per_day_; 
                     END IF;
                     count_ := 0;
                     IF (max_per_day_ > 0 AND inv_max_ord_qty_ > 0 AND inv_max_ord_qty_ < max_order_qty_ AND max_per_day_ > inv_max_ord_qty_) THEN                  
                        WHILE (max_per_day_ >= inv_max_ord_qty_) LOOP
                           Create_New_Mps___(mps_arr_, local_index_, inv_max_ord_qty_, contract_, part_no_, png_, ms_set_, ptf_date_, start_crp_calc_,
                                             shop_order_proposal_flag_db_, calendar_id_);
                           max_per_day_ := max_per_day_ - inv_max_ord_qty_;
                           count_ := count_ + 1;
                        END LOOP;
                     END IF;
                     -- If remaining quantity is less than minimum order quantity, increase to miniumum
                     IF (max_per_day_ > 0) THEN
                        IF inventory_part_plan_rec_.min_order_qty != 0 AND inventory_part_plan_rec_.min_order_qty > max_per_day_ THEN
                           IF (((count_ * inv_max_ord_qty_) + inventory_part_plan_rec_.min_order_qty) <= max_order_qty_ ) THEN
                              max_per_day_ := inventory_part_plan_rec_.min_order_qty;
                           ELSE
                              qty_to_plan_ := qty_to_plan_ + max_per_day_;
                              CONTINUE; 
                           END IF;
                        END IF;
                        Create_New_Mps___(mps_arr_, local_index_, max_per_day_, contract_, part_no_, png_, ms_set_, ptf_date_, start_crp_calc_,
                                          shop_order_proposal_flag_db_, calendar_id_);
                     END IF;
                  END IF;
               ELSE
                  qty_to_plan_ := qty_to_plan_ - mps_on_orig_date_;
               END IF;
               first_iteration_ := FALSE;  
               IF (qty_to_plan_ = 0) THEN
                  used_required_date_ := mps_arr_(current_index_).work_day;
                  mps_on_date_ := mps_on_orig_date_;
               END IF;         
            END LOOP;
            
            Trace_Sys.Message('*** mps_on_date_ - max_order_qty_ - mps_on_orig_date_ '||mps_on_date_||' '||max_order_qty_||' '||mps_on_orig_date_||' ***');  
               
            IF ((mps_on_date_ > max_order_qty_ OR ( unit_ = u_week_ AND max_order_qty_ - mps_on_orig_date_ + mps_on_date_ > max_order_qty_)) 
              AND used_required_date_ = mps_arr_(current_index_).work_day) THEN
               IF NOT (Level_1_Message_API.Check_Exist_On_Date (
                                contract_        =>   contract_,
                                part_no_         =>   part_no_,
                                png_             =>   png_,
                                ms_set_          =>   ms_set_,
                                ms_date_         =>   mps_arr_(current_index_).work_day,
                                msg_code_        =>   'E529')) THEN
                   Level_1_Message_API.Batch_New__(
                           contract_      => contract_,
                           part_no_       => part_no_,
                           png_           => png_,
                           ms_set_        => ms_set_,
                           ms_date_       => mps_arr_(current_index_).work_day,
                           order_no_      => NULL,
                           line_no_       => NULL,
                           release_no_    => NULL,
                           line_item_no_  => NULL,
                           order_type_db_ => NULL,
                           activity_seq_  => NULL,
                           msg_code_      => 'E529');
               END IF;
            END IF;
            IF (mps_on_date_ > 0 OR mps_on_orig_date_ > 0) THEN
               IF (infinite_capacity_ = TRUE AND mps_on_orig_date_ > 0) THEN  
                  local_index_ := Find_Local_Index___(mps_arr_, mps_arr_(current_index_).work_day);
                  --Trace_SYS.Message('Create MS receipt after loop with '||mps_arr_(current_index_).work_day||' and qty '||mps_on_orig_date_);
                  IF (inv_max_ord_qty_ = 0 OR inv_max_ord_qty_ > mps_on_orig_date_) THEN
                     Create_New_Mps___(mps_arr_, local_index_, mps_on_orig_date_, contract_, part_no_, png_, ms_set_, ptf_date_, start_crp_calc_,
                                       shop_order_proposal_flag_db_, calendar_id_);
                  ELSE 
                     mps_size_ := inv_max_ord_qty_;
                     count_ := 0;
                     WHILE (mps_on_orig_date_ >= mps_size_) LOOP
                        count_ := count_ + 1;
                        Create_New_Mps___(mps_arr_, local_index_, mps_size_, contract_, part_no_, png_, ms_set_, ptf_date_, start_crp_calc_,
                                          shop_order_proposal_flag_db_, calendar_id_);                                      
                        mps_on_orig_date_ := mps_on_orig_date_ - mps_size_;
                     END LOOP;
                     IF (mps_on_orig_date_ > 0) THEN
                        IF inventory_part_plan_rec_.min_order_qty != 0 AND inventory_part_plan_rec_.min_order_qty >= mps_on_orig_date_ THEN
                           IF (((count_ * mps_size_) + inventory_part_plan_rec_.min_order_qty)<= max_order_qty_ ) THEN
                              mps_on_orig_date_ := inventory_part_plan_rec_.min_order_qty;
                           ELSE
                              mps_on_date_ := mps_on_date_ + mps_on_orig_date_;
                              mps_on_orig_date_ := 0;
                           END IF;
                        END IF;
                        IF (mps_on_orig_date_ > 0) THEN
                           Create_New_Mps___(mps_arr_, local_index_, mps_on_orig_date_, contract_, part_no_, png_, ms_set_, ptf_date_, start_crp_calc_,
                                             shop_order_proposal_flag_db_, calendar_id_);
                        END IF;
                     END IF;
                  END IF;
               END IF;          
               local_index_ := Find_Local_Index___(mps_arr_, used_required_date_);
               ms_receipt_ := 0;           
               OPEN get_ms_receipt(used_required_date_);
               FETCH get_ms_receipt INTO ms_receipt_;
               CLOSE get_ms_receipt;
               IF (ms_receipt_ > 0 AND mps_on_date_ > 0) THEN
                  OPEN get_receipt(used_required_date_);
                  FETCH get_receipt INTO line_no_;
                  CLOSE get_receipt;  
                  Ms_Receipt_API.Batch_Remove__(
                                    contract_,
                                    part_no_,
                                    png_,
                                    ms_set_,
                                    used_required_date_,
                                    line_no_);               
                  line_no_ := 0;          
                  Level_1_Forecast_API.Batch_Modify__ (
                     contract_            => contract_,
                     part_no_             => part_no_,
                     png_                 => png_,
                     ms_set_              => ms_set_,
                     activity_seq_        => 0,
                     ms_date_             => used_required_date_,
                     parent_contract_     => NULL,
                     parent_part_         => NULL,
                     forecast_lev0_       => NULL,
                     forecast_lev1_       => NULL,
                     consumed_forecast_   => NULL,
                     actual_demand_       => NULL,
                     planned_demand_      => NULL,
                     supply_              => NULL,
                     consumed_supply_     => NULL,
                     firm_orders_         => NULL,
                     sched_orders_        => NULL,
                     rel_ord_rcpt_        => NULL,
                     master_sched_rcpt_   => 0,
                     avail_to_prom_       => NULL,
                     roll_up_rcpt_        => NULL,
                     net_avail_           => NULL,
                     proj_avail_          => NULL,
                     mtr_demand_qty_      => NULL,
                     mtr_supply_qty_      => NULL,
                     offset_              => NULL,
                     roll_flag_db_        => NULL,
                     sysgen_flag_         => NULL,
                     master_sched_status_ => NULL,
                     method_              => 'UPDATE' );
   
                  FOR i IN local_index_ .. mps_arr_.LAST LOOP
                     mps_arr_(i).projected_onhand := mps_arr_(i).projected_onhand - ms_receipt_;
                  END LOOP;
                  mps_on_date_ := mps_on_date_ + ms_receipt_;
               END IF;
               IF inv_max_ord_qty_ = 0 THEN
                  Create_New_Mps___(mps_arr_, local_index_, mps_on_date_, contract_, part_no_, png_, ms_set_, ptf_date_, start_crp_calc_,
                                    shop_order_proposal_flag_db_, calendar_id_); 
               ELSE
                  mps_size_ := inv_max_ord_qty_;
                  WHILE (mps_on_date_ >= mps_size_) LOOP
                     Create_New_Mps___(mps_arr_, local_index_, mps_size_, contract_, part_no_, png_, ms_set_, ptf_date_, start_crp_calc_,
                                       shop_order_proposal_flag_db_, calendar_id_);                                      
                     mps_on_date_ := mps_on_date_ - mps_size_;
                  END LOOP;
                  IF (mps_on_date_ > 0) THEN
                     IF inventory_part_plan_rec_.min_order_qty != 0 AND inventory_part_plan_rec_.min_order_qty >= mps_on_date_ THEN
                        mps_on_date_ := inventory_part_plan_rec_.min_order_qty;
                     END IF;
                     Create_New_Mps___(mps_arr_, local_index_, mps_on_date_, contract_, part_no_, png_, ms_set_, ptf_date_, start_crp_calc_,
                                       shop_order_proposal_flag_db_, calendar_id_);
                  END IF;
               END IF;
            END IF;    
         ELSE
            -- Create planned supplies with max order quantity rules
            -- Create as many supplies of max size to fulfill supply without going over
            qty_to_plan_ := local_mps_;
            order_gap_time_ := Manuf_Part_Attribute_API.Get_Order_Gap_Time(contract_, part_no_);
            IF (inventory_part_plan_rec_.mul_order_qty > 0) THEN
               max_order_qty_ := inventory_part_plan_rec_.mul_order_qty * FLOOR(max_order_qty_ / inventory_part_plan_rec_.mul_order_qty);
            END IF;
            
            WHILE (qty_to_plan_ > max_order_qty_) LOOP
               -- Trace_Sys.Message('Within max size loop '||mps_arr_(current_index_).work_day ||' '||qty_to_plan_||' '||max_order_qty_);
               used_required_counter_ := Work_Time_Calendar_API.Get_Work_Day_Counter(calendar_id_, mps_arr_(current_index_).work_day) - 
                                         CEIL(order_gap_time_ * no_of_orders_);
               
               used_required_date_ := Work_Time_Calendar_API.Get_Work_Day(calendar_id_, used_required_counter_);                          
               IF (used_required_date_<= ptf_date_) THEN
                  RAISE ptf_crossed_;
               END IF;                          
                                         
               local_index_ := Find_Local_Index___(mps_arr_, used_required_date_);
               IF local_index_ = -1 THEN
                  Error_Sys.Appl_General(lu_name_, 'INVALIDREQDATE: System cannot proceed with MPS generation for used required date :P1.', used_required_date_);
               END IF;
               Create_New_Mps___(mps_arr_, local_index_, max_order_qty_, contract_, part_no_, png_, ms_set_, ptf_date_, start_crp_calc_,
                                 shop_order_proposal_flag_db_, calendar_id_);
                                               
               qty_to_plan_ := qty_to_plan_ - max_order_qty_;
               no_of_orders_ := no_of_orders_ + 1;
      
            END LOOP;
            
            -- Create supply for remaining quantity
            IF (qty_to_plan_ > 0) THEN
            -- If remaining quantity is less than minimum order quantity, increase to miniumu
               IF inventory_part_plan_rec_.min_order_qty != 0 AND inventory_part_plan_rec_.min_order_qty >= qty_to_plan_ THEN
                  qty_to_plan_ := inventory_part_plan_rec_.min_order_qty;
               END IF;
               -- Continue with multiple order qty rule
               IF inventory_part_plan_rec_.mul_order_qty != 0 AND qty_to_plan_ > 0 THEN
                  qty_to_plan_ := inventory_part_plan_rec_.mul_order_qty * CEIL(qty_to_plan_ / inventory_part_plan_rec_.mul_order_qty);
               END IF;
               
               used_required_counter_ := Work_Time_Calendar_API.Get_Work_Day_Counter(calendar_id_, mps_arr_(current_index_).work_day) - 
                                         CEIL(order_gap_time_ * no_of_orders_);
               
               used_required_date_ := Work_Time_Calendar_API.Get_Work_Day(calendar_id_, used_required_counter_);                          
               IF (used_required_date_<= ptf_date_) THEN
                  RAISE ptf_crossed_;
               END IF;                          
                                         
               local_index_ := Find_Local_Index___(mps_arr_, used_required_date_);
               IF local_index_ = -1 THEN
                  Error_Sys.Appl_General(lu_name_, 'INVALIDREQDATE: System cannot proceed with MPS generation for used required date :P1.', used_required_date_);
               END IF;
      
               Create_New_Mps___(mps_arr_, local_index_, qty_to_plan_, contract_, part_no_, png_, ms_set_, ptf_date_, start_crp_calc_,
                                 shop_order_proposal_flag_db_, calendar_id_);
            END IF;
         END IF;
      ELSE
         Std_Mul_Qty_Calculation___(mps_arr_,
                                    current_index_,
                                    local_mps_,
                                    contract_,
                                    part_no_,
                                    png_,
                                    ms_set_,
                                    ptf_date_,
                                    shop_order_proposal_flag_db_,
                                    calendar_id_);
      END IF;
   EXCEPTION
      WHEN ptf_crossed_ THEN
         IF NOT (Level_1_Message_API.Check_Exist_On_Date (
                             contract_        =>   contract_,
                             part_no_         =>   part_no_,
                             png_             =>   png_,
                             ms_set_          =>   ms_set_,
                             ms_date_         =>   ptf_date_,
                             msg_code_        =>   'E539')) THEN
            Level_1_Message_API.Batch_New__(
                        contract_      => contract_,
                        part_no_       => part_no_,
                        png_           => png_,
                        ms_set_        => ms_set_,
                        ms_date_       => ptf_date_,
                        order_no_      => NULL,
                        line_no_       => NULL,
                        release_no_    => NULL,
                        line_item_no_  => NULL,
                        order_type_db_ => NULL,
                        activity_seq_  => NULL,
                        msg_code_      => 'E539');
         END IF;
      WHEN OTHERS THEN
         IF Error_SYS.Is_Foundation_Error(SQLCODE) THEN
            RAISE;
         END IF;
   
         local_contract_ := contract_ || ', Part No ' || part_no_;
   
         Error_Sys.Appl_General (lu_name_, 'INSMSORD: Error :P1 occurred while running LEVEL_1_FORECAST_UTIL_API.Lot_Size_And_Create_New_Mps___ for Site :P2 MS Set :P3.', SQLERRM, local_contract_, ms_set_);
   END Core;

BEGIN
   Core(mps_arr_, current_index_, new_mps_, contract_, part_no_, png_, ms_set_, ptf_date_, calendar_id_, inventory_part_plan_rec_, start_crp_calc_, shop_order_proposal_flag_db_, lead_time_code_db_);
END Lot_Size_And_Create_New_Mps___;


PROCEDURE Create_New_Mps___ (
   mps_arr_                     IN OUT NOCOPY Mps_Array_,
   current_index_               IN PLS_INTEGER,
   new_mps_                     IN NUMBER,
   contract_                    IN VARCHAR2,
   part_no_                     IN VARCHAR2,
   png_                         IN VARCHAR2,
   ms_set_                      IN VARCHAR2,
   ptf_date_                    IN DATE,
   start_crp_calc_              IN BOOLEAN,
   shop_order_proposal_flag_db_ IN VARCHAR2,
   calendar_id_                 IN VARCHAR2,
   vendor_no_                   IN VARCHAR2 DEFAULT NULL )
IS
   
   PROCEDURE Core (
      mps_arr_                     IN OUT NOCOPY Mps_Array_,
      current_index_               IN PLS_INTEGER,
      new_mps_                     IN NUMBER,
      contract_                    IN VARCHAR2,
      part_no_                     IN VARCHAR2,
      png_                         IN VARCHAR2,
      ms_set_                      IN VARCHAR2,
      ptf_date_                    IN DATE,
      start_crp_calc_              IN BOOLEAN,
      shop_order_proposal_flag_db_ IN VARCHAR2,
      calendar_id_                 IN VARCHAR2,
      vendor_no_                   IN VARCHAR2 DEFAULT NULL )
   IS
      rounded_supply_qty_ NUMBER;
      master_sched_rcpt_  NUMBER;
      local_index_        PLS_INTEGER:= current_index_;
      dummy_              NUMBER;
      ms_date_            DATE;
      local_contract_     VARCHAR2(200);
      line_no_            NUMBER;
      
      CURSOR check_fixed (ms_date_ DATE, activity_seq_ NUMBER) IS
         SELECT 1
         FROM LEVEL_1_FORECAST_TAB
         WHERE contract     = contract_
         AND   part_no      = part_no_
         AND   png          = png_
         AND   ms_set       = ms_set_
         AND   activity_seq = activity_seq_
         AND   ms_date      = ms_date_
         AND   sysgen_flag  = sysgen_no_
         AND   NVL(master_sched_rcpt, 0) > 0;
        
   BEGIN
      
      rounded_supply_qty_ := Inventory_Part_API.Get_Calc_Rounded_Qty(contract_, part_no_, new_mps_);
      master_sched_rcpt_ := Inventory_Part_Planning_API.Get_Scrap_Removed_Qty(contract_, part_no_, rounded_supply_qty_);
      
      -- Do not put our new ms receipt on a date where we have a fixed ms receipt
      LOOP 
         EXIT WHEN local_index_ < mps_arr_.FIRST;
         OPEN check_fixed(mps_arr_(local_index_).work_day, mps_arr_(local_index_).ms_receipt_activity_seq);
         FETCH check_fixed INTO dummy_;
         EXIT WHEN check_fixed%NOTFOUND;
         CLOSE check_fixed;
         --Trace_SYS.Message('Local Index '||local_index_);
         local_index_ := local_index_ - 1;
      END LOOP;
   
      IF (check_fixed%ISOPEN) THEN
         CLOSE check_fixed;
      END IF;
      
      IF local_index_ < mps_arr_.FIRST THEN
         -- MS plan has to be adjusted manually as a fixed proposal exists in the first period beyond the PTF.
         IF NOT (Level_1_Message_API.Check_Exist_On_Date (
                             contract_        =>   contract_,
                             part_no_         =>   part_no_,
                             png_             =>   png_,
                             ms_set_          =>   ms_set_,
                             ms_date_         =>   ptf_date_,
                             msg_code_        =>   'E542')) THEN
            Level_1_Message_API.Batch_New__(
                        contract_      => contract_,
                        part_no_       => part_no_,
                        png_           => png_,
                        ms_set_        => ms_set_,
                        ms_date_       => ptf_date_,
                        order_no_      => NULL,
                        line_no_       => NULL,
                        release_no_    => NULL,
                        line_item_no_  => NULL,
                        order_type_db_ => NULL,
                        activity_seq_  => mps_arr_(current_index_).ms_receipt_activity_seq,
                        msg_code_      => 'E542');
         END IF;
         local_index_ := Find_Local_Index_Backward___(mps_arr_, mps_arr_(current_index_).work_day + 1);
         ms_date_ := mps_arr_(local_index_).work_day;
         -- Going forward and find a date where we don't have fixed proposals
         LOOP 
            OPEN check_fixed(ms_date_, mps_arr_(current_index_).ms_receipt_activity_seq);
            FETCH check_fixed INTO dummy_;
            EXIT WHEN check_fixed%NOTFOUND;
            CLOSE check_fixed;
            local_index_ := Find_Local_Index_Backward___(mps_arr_, ms_date_+1);
            ms_date_ := mps_arr_(local_index_).work_day;
         END LOOP;
   
         IF (check_fixed%ISOPEN) THEN
            CLOSE check_fixed;
         END IF;
         
         IF (local_index_ = -1) THEN
            local_index_ := mps_arr_.LAST + 1;    
            mps_arr_(local_index_).work_day := ms_date_;
            mps_arr_(local_index_).ms_receipt_activity_seq := mps_arr_(current_index_).ms_receipt_activity_seq;
         END IF;
      END IF;
      
      Ms_Receipt_API.Batch_New__(
               line_no_             => line_no_,
               contract_            => contract_,
               part_no_             => part_no_,
               png_                 => png_,
               ms_set_              => ms_set_,
               ms_date_             => mps_arr_(local_index_).work_day,
               activity_seq_        => mps_arr_(local_index_).ms_receipt_activity_seq,
               master_sched_rcpt_   => rounded_supply_qty_,
               sysgen_flag_         => sysgen_yes_,
               start_crp_calc_      => start_crp_calc_,
               shop_order_proposal_flag_db_ => shop_order_proposal_flag_db_,
               calendar_id_         => calendar_id_,
   	         vendor_no_		      => vendor_no_);
   
      IF NOT Level_1_Forecast_API.Check_Exist(contract_, part_no_, png_, ms_set_, mps_arr_(local_index_).ms_receipt_activity_seq,
                                              mps_arr_(local_index_).work_day) THEN
         Level_1_Forecast_API.Batch_New__(
            contract_            => contract_,
            part_no_             => part_no_,
            png_                 => png_,
            ms_set_              => ms_set_,
            activity_seq_        => mps_arr_(local_index_).ms_receipt_activity_seq,
            ms_date_             => mps_arr_(local_index_).work_day,
            parent_contract_     => NULL,
            parent_part_         => NULL,        
            forecast_lev0_       => 0,
            forecast_lev1_       => 0,
            consumed_forecast_   => 0,
            actual_demand_       => 0,
            planned_demand_      => 0,
            supply_              => 0,
            consumed_supply_     => 0,
            firm_orders_         => 0,
            sched_orders_        => 0,
            rel_ord_rcpt_        => 0,
            master_sched_rcpt_   => master_sched_rcpt_,
            avail_to_prom_       => 0,
            roll_up_rcpt_        => NULL,
            net_avail_           => 0,
            proj_avail_          => 0,
            mtr_demand_qty_      => 0,
            mtr_supply_qty_      => 0,
            offset_              => NULL,
            sysgen_flag_         => Sysgen_API.Decode(sysgen_yes_),
            master_sched_status_ => Master_Sched_Status_API.Get_Client_Value(0) );
      ELSE
         Level_1_Forecast_API.Batch_Modify__ (
            contract_            => contract_,
            part_no_             => part_no_,
            png_                 => png_,
            ms_set_              => ms_set_,
            activity_seq_        => mps_arr_(local_index_).ms_receipt_activity_seq,
            ms_date_             => mps_arr_(local_index_).work_day,
            parent_contract_     => NULL,
            parent_part_         => NULL,
            forecast_lev0_       => NULL,
            forecast_lev1_       => NULL,
            consumed_forecast_   => NULL,
            actual_demand_       => NULL,
            planned_demand_      => NULL,
            supply_              => NULL,
            consumed_supply_     => NULL,
            firm_orders_         => NULL,
            sched_orders_        => NULL,
            rel_ord_rcpt_        => NULL,
            master_sched_rcpt_   => master_sched_rcpt_,
            avail_to_prom_       => NULL,
            roll_up_rcpt_        => NULL,
            net_avail_           => NULL,
            proj_avail_          => NULL,
            mtr_demand_qty_      => NULL,
            mtr_supply_qty_      => NULL,
            offset_              => NULL,
            roll_flag_db_        => NULL,
            sysgen_flag_         => NULL,
            master_sched_status_ => NULL,
            method_              => 'ADD' );
   
      END IF;
   
      FOR i IN local_index_ .. mps_arr_.LAST LOOP
         mps_arr_(i).projected_onhand := mps_arr_(i).projected_onhand + master_sched_rcpt_;
      END LOOP;
      
   EXCEPTION
      WHEN OTHERS THEN
         IF Error_SYS.Is_Foundation_Error(SQLCODE) THEN
            RAISE;
         END IF; 
      
         local_contract_ := contract_ || ', Part No ' || part_no_;
   
         Error_Sys.Appl_General (lu_name_, 'INSMSORD01: Error :P1 occurred while running LEVEL_1_FORECAST_UTIL_API.Create_New_Mps___ for Site :P2 MS Set :P3.', SQLERRM, local_contract_, ms_set_);
   END Core;

BEGIN
   Core(mps_arr_, current_index_, new_mps_, contract_, part_no_, png_, ms_set_, ptf_date_, start_crp_calc_, shop_order_proposal_flag_db_, calendar_id_, vendor_no_);
END Create_New_Mps___;


FUNCTION Find_Local_Index___ (
   mps_arr_    IN Mps_Array_,
   work_day_   IN DATE ) RETURN PLS_INTEGER
IS
   
   FUNCTION Core (
      mps_arr_    IN Mps_Array_,
      work_day_   IN DATE ) RETURN PLS_INTEGER
   IS
   BEGIN
      FOR i IN mps_arr_.FIRST .. mps_arr_.LAST LOOP
         IF mps_arr_(i).work_day = work_day_ THEN
            RETURN i;
         END IF;
      END LOOP;
      RETURN -1;
   END Core;

BEGIN
   RETURN Core(mps_arr_, work_day_);
END Find_Local_Index___;


FUNCTION Find_Local_Index___ (
   mps_arr_    IN Mps_Array_,
   counter_    IN NUMBER ) RETURN PLS_INTEGER
IS
   
   FUNCTION Core (
      mps_arr_    IN Mps_Array_,
      counter_    IN NUMBER ) RETURN PLS_INTEGER
   IS
   BEGIN
      FOR i IN mps_arr_.FIRST .. mps_arr_.LAST LOOP
         IF mps_arr_(i).counter = counter_ THEN
            RETURN i;
         END IF;
      END LOOP;
      RETURN -1;
   END Core;

BEGIN
   RETURN Core(mps_arr_, counter_);
END Find_Local_Index___;


FUNCTION Find_Local_Index_Forward___ (
   mps_arr_    IN Mps_Array_,
   work_day_   IN DATE ) RETURN PLS_INTEGER
IS
   
   FUNCTION Core (
      mps_arr_    IN Mps_Array_,
      work_day_   IN DATE ) RETURN PLS_INTEGER
   IS
   BEGIN
      FOR i IN mps_arr_.FIRST .. mps_arr_.LAST LOOP
         IF mps_arr_(i).work_day = work_day_ THEN
            RETURN i;
         ELSIF mps_arr_(i).work_day > work_day_ AND i != mps_arr_.FIRST THEN
            RETURN i-1;
         END IF;
      END LOOP;
      RETURN -1;
   END Core;

BEGIN
   RETURN Core(mps_arr_, work_day_);
END Find_Local_Index_Forward___;


FUNCTION Find_Local_Index_Backward___ (
   mps_arr_    IN Mps_Array_,
   work_day_   IN DATE ) RETURN PLS_INTEGER
IS
   
   FUNCTION Core (
      mps_arr_    IN Mps_Array_,
      work_day_   IN DATE ) RETURN PLS_INTEGER
   IS
   BEGIN
      FOR i IN REVERSE mps_arr_.FIRST .. mps_arr_.LAST LOOP
         IF mps_arr_(i).work_day = work_day_ THEN
            RETURN i;
         ELSIF mps_arr_(i).work_day < work_day_ AND i != mps_arr_.LAST THEN
            RETURN i+1;
         END IF;
      END LOOP;
      RETURN -1;
   END Core;

BEGIN
   RETURN Core(mps_arr_, work_day_);
END Find_Local_Index_Backward___;


FUNCTION Get_Available_Mps_For_Week___ (
   contract_                    IN VARCHAR2,
   part_no_                     IN VARCHAR2,
   png_                         IN VARCHAR2,
   ms_set_                      IN NUMBER,
   used_required_date_          IN DATE,
   max_size_                    IN NUMBER,
   orig_fcst_date_              IN DATE,
   qty_to_plan_                 IN NUMBER,
   week_start_                  IN DATE DEFAULT NULL ) RETURN NUMBER
IS
   
   FUNCTION Core (
      contract_                    IN VARCHAR2,
      part_no_                     IN VARCHAR2,
      png_                         IN VARCHAR2,
      ms_set_                      IN NUMBER,
      used_required_date_          IN DATE,
      max_size_                    IN NUMBER,
      orig_fcst_date_              IN DATE,
      qty_to_plan_                 IN NUMBER,
      week_start_                  IN DATE DEFAULT NULL ) RETURN NUMBER
   IS
      available_to_schedule_  NUMBER;
      week_start1_            DATE := week_start_;
      ms_receipt_total_       NUMBER := 0; 
      
      CURSOR get_ms_receipt IS
         SELECT NVL(SUM(master_sched_rcpt),0)
         FROM LEVEL_1_FORECAST_TAB
         WHERE contract    = contract_
         AND   part_no     = part_no_
         AND   png         = png_
         AND   ms_set      = ms_set_
         AND   ms_date BETWEEN week_start1_ AND (week_start1_ + 6)
         AND   NVL(master_sched_rcpt, 0) > 0;
      
   BEGIN
      IF qty_to_plan_ < max_size_ THEN
         available_to_schedule_ := qty_to_plan_;
      ELSE
         available_to_schedule_ := max_size_;
      END IF;
      IF week_start1_ IS NULL THEN
         -- Get latest Monday
         week_start1_ := TRUNC(used_required_date_, 'IW');
      END IF;
      
      IF orig_fcst_date_ BETWEEN week_start1_ AND (week_start1_+6) THEN
         RETURN 0;
      END IF;
      
      OPEN get_ms_receipt;
      FETCH get_ms_receipt INTO ms_receipt_total_;
      CLOSE get_ms_receipt;                   
         
      IF max_size_ < ms_receipt_total_ THEN
         available_to_schedule_ := 0;        
      ELSIF available_to_schedule_ >= max_size_ - ms_receipt_total_ THEN         
         available_to_schedule_ := max_size_ - ms_receipt_total_; 
      END IF;
      RETURN available_to_schedule_;
   END Core;

BEGIN
   RETURN Core(contract_, part_no_, png_, ms_set_, used_required_date_, max_size_, orig_fcst_date_, qty_to_plan_, week_start_);
END Get_Available_Mps_For_Week___;


PROCEDURE Std_Mul_Qty_Calculation___ (
   mps_arr_                     IN OUT NOCOPY Mps_Array_,
   current_index_               IN PLS_INTEGER,
   new_mps_                     IN NUMBER,
   contract_                    IN VARCHAR2,
   part_no_                     IN VARCHAR2,
   png_                         IN VARCHAR2,
   ms_set_                      IN NUMBER,
   ptf_date_                    IN DATE,
   shop_order_proposal_flag_db_ IN VARCHAR2,
   calendar_id_                 IN VARCHAR2 )
IS
   
   PROCEDURE Core (
      mps_arr_                     IN OUT NOCOPY Mps_Array_,
      current_index_               IN PLS_INTEGER,
      new_mps_                     IN NUMBER,
      contract_                    IN VARCHAR2,
      part_no_                     IN VARCHAR2,
      png_                         IN VARCHAR2,
      ms_set_                      IN NUMBER,
      ptf_date_                    IN DATE,
      shop_order_proposal_flag_db_ IN VARCHAR2,
      calendar_id_                 IN VARCHAR2 )
   IS
      order_qty_                    NUMBER;
      contract_part_no_info_        VARCHAR2(200);
      -- Bug 122356, start
      cur_row_                      PLS_INTEGER;
      part_status_                  VARCHAR2(20);
      part_stat_rec_                INVENTORY_PART_STATUS_PAR_API.Public_Rec;
      -- Bug 122356, end
   BEGIN
      
      $IF Component_Purch_SYS.INSTALLED $THEN
         DECLARE
            part_supplier_collection_   Supply_Source_Part_Manager_API.Part_Supplier_Collection;
            -- Bug 122356, start
            part_supplier_collection_tmp_    Supply_Source_Part_Manager_API.Part_Supplier_Collection;
            -- Bug 122356, end
            req_qty_                    NUMBER;
            total_split_percentage_     NUMBER;
            remaining_qty_              NUMBER;
            qty_created_                NUMBER;
         BEGIN
            req_qty_ := Inventory_Part_API.Get_Calc_Rounded_Qty(contract_, part_no_, new_mps_);
   
            -- Fetch supplier details.
            Supply_Source_Part_Manager_API.Collect_Supplier_List (part_supplier_collection_tmp_,
                                                                  contract_,
                                                                  part_no_,
                                                                  mps_arr_(current_index_).work_day,
                                                                  NULL);
   
            -- Bug 122356, start
            IF part_supplier_collection_tmp_.COUNT > 0 THEN
               FOR row_index IN part_supplier_collection_tmp_.FIRST .. part_supplier_collection_tmp_.LAST LOOP
                  part_status_ := Inventory_Part_API.Get_Part_Status(part_supplier_collection_tmp_(row_index).supplying_site, part_no_);
                  part_stat_rec_  := Inventory_Part_Status_Par_API.Get(part_status_);                     
                  IF ((part_supplier_collection_tmp_(row_index).category_db = 'E') OR (part_supplier_collection_tmp_(row_index).category_db = 'I' AND part_stat_rec_.demand_flag = 'Y')) THEN
                     cur_row_ := NVL(part_supplier_collection_.LAST, 0) + 1;
                     part_supplier_collection_(cur_row_).vendor_no                  := part_supplier_collection_tmp_(row_index).vendor_no;
                     part_supplier_collection_(cur_row_).supplying_site             := part_supplier_collection_tmp_(row_index).supplying_site;
                     part_supplier_collection_(cur_row_).category_db                := part_supplier_collection_tmp_(row_index).category_db;
                     part_supplier_collection_(cur_row_).primary_vendor_db          := part_supplier_collection_tmp_(row_index).primary_vendor_db;
                     part_supplier_collection_(cur_row_).multisite_planned_part_db  := part_supplier_collection_tmp_(row_index).multisite_planned_part_db;
                     part_supplier_collection_(cur_row_).phase_in_date              := part_supplier_collection_tmp_(row_index).phase_in_date;
                     part_supplier_collection_(cur_row_).phase_out_date             := part_supplier_collection_tmp_(row_index).phase_out_date;
                     part_supplier_collection_(cur_row_).split_percentage           := part_supplier_collection_tmp_(row_index).split_percentage;
                     part_supplier_collection_(cur_row_).std_multiple_qty           := part_supplier_collection_tmp_(row_index).std_multiple_qty;                    
                  END IF;                  
               END LOOP;
            END IF;
            part_supplier_collection_tmp_.Delete;                        
            -- Bug 122356, end
              
            total_split_percentage_ := 0;
            IF part_supplier_collection_.COUNT > 0 THEN
               FOR row_index IN part_supplier_collection_.FIRST .. part_supplier_collection_.LAST LOOP
                  total_split_percentage_ := total_split_percentage_ + part_supplier_collection_(row_index).split_percentage; 
               END LOOP;
            END IF;
   
            IF part_supplier_collection_.COUNT = 0 OR total_split_percentage_ = 0 THEN
               part_supplier_collection_(0).vendor_no                  := NULL;
               part_supplier_collection_(0).supplying_site             := NULL;
               part_supplier_collection_(0).category_db                := 'E';
               part_supplier_collection_(0).primary_vendor_db          := NULL;
               part_supplier_collection_(0).multisite_planned_part_db  := 'NOT_MULTISITE_PLAN';
               part_supplier_collection_(0).phase_in_date              := mps_arr_(current_index_).work_day;
               part_supplier_collection_(0).phase_out_date             := NULL;
               part_supplier_collection_(0).split_percentage           := 100;
               part_supplier_collection_(0).std_multiple_qty           := 0;
               -- Bug 122356, start
               total_split_percentage_ := 100;
               -- Bug 122356, end
            END IF;
   
            IF req_qty_ > 0 AND part_supplier_collection_.COUNT > 0 THEN
               remaining_qty_ := req_qty_;
               qty_created_   := 0;
   
               FOR row_index IN part_supplier_collection_.FIRST .. part_supplier_collection_.LAST LOOP
                  order_qty_ := 0;
                  EXIT WHEN (remaining_qty_ <= 0);
   
                  order_qty_ := ROUND(part_supplier_collection_(row_index).split_percentage/total_split_percentage_ * req_qty_);
                  
                  IF (order_qty_ > remaining_qty_) THEN
                     order_qty_ := remaining_qty_;
                  END IF;
   
                  IF order_qty_ > 0 THEN
                     IF (NVL(part_supplier_collection_(row_index).std_multiple_qty, 0) <> 0) THEN  -- Considering Std_Mul_Qty
                        IF (MOD(order_qty_, part_supplier_collection_(row_index).std_multiple_qty) <> 0) THEN
                           order_qty_ := order_qty_ - MOD(order_qty_, part_supplier_collection_(row_index).std_multiple_qty) + part_supplier_collection_(row_index).std_multiple_qty;
                        END IF;
                     END IF;
                     
                     -- Trace_SYS.Message('*** Supplier No ' ||part_supplier_collection_(row_index).vendor_no ||' date '||mps_arr_(current_index_).work_day||' qty '||order_qty_);
   
                     Create_New_Mps___(mps_arr_,
                                       current_index_,
                                       order_qty_,
                                       contract_,
                                       part_no_,
                                       png_,
                                       ms_set_,
                                       ptf_date_,
                                       FALSE,
                                       shop_order_proposal_flag_db_,
                                       calendar_id_,
                                       part_supplier_collection_(row_index).vendor_no);
   
                     remaining_qty_ := remaining_qty_ - order_qty_;
                     qty_created_ := NVL(qty_created_, 0) + order_qty_;
                  END IF;
               END LOOP; -- End of suppliers loop
               part_supplier_collection_.Delete;
            END IF;
            part_supplier_collection_.Delete;
         END;
      $ELSE
         NULL;
      $END
   EXCEPTION
      WHEN OTHERS THEN
         IF Error_SYS.Is_Foundation_Error(SQLCODE) THEN
            RAISE;
         END IF;
   
         contract_part_no_info_ := contract_ || ', part no ' || part_no_;
   
         Error_Sys.Appl_General(lu_name_, 'STDMULQTYCALC: Error :P1 occurred while running LEVEL_1_FORECAST_UTIL_API.Std_Mul_Qty_Calculation__ for the site :P2 of MS set :P3.',
                                SQLERRM,
                                contract_part_no_info_,
                                ms_set_);
   END Core;

BEGIN
   Core(mps_arr_, current_index_, new_mps_, contract_, part_no_, png_, ms_set_, ptf_date_, shop_order_proposal_flag_db_, calendar_id_);
END Std_Mul_Qty_Calculation___;

-----------------------------------------------------------------------------
-------------------- FOUNDATION1 METHODS ------------------------------------
-----------------------------------------------------------------------------


--@IgnoreMissingSysinit
PROCEDURE Init
IS
   
   PROCEDURE Base
   IS
   BEGIN
      NULL;
   END Base;

BEGIN
   Base;
END Init;

BEGIN
   Init;
END LEVEL_1_FORECAST_UTIL_API;
/
