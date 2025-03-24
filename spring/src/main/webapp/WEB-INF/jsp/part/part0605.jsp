<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 부품통계 > 부품자료다운관리 > null > null
-- 작성자 : 손광진
-- 최초 작성일 : 2020-09-08 16:18:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var oldRadioId;				// 기존 체크한 라디오 ID
		var oldRadioCheck = false;  // 기존 라디오 체크여부

		var homiList = ${homiList};

		$(document).ready(function() {
			// 그리드 생성
			createAUIGrid1();
			createAUIGrid2();
			createAUIGrid3();
			createAUIGrid4();
			createAUIGrid5();
			createAUIGrid6();
			createAUIGrid7();
			createExcelGrid();


			$(document).on("click", "input[type=radio]", function(e) {

				var newRadioCheck   = $('input:radio[name=s_excel_down_type]').is(':checked'); // 라디오 체크 여부
				var newRadioId    	= $(this).attr('id');	// 체크한 라디오 ID

				if(oldRadioCheck == newRadioCheck) {
					// 이미 체크한 라디오박스 일 때 체크해제
					$("input:radio[id='" + oldRadioId + "']").prop("checked", false);
					oldRadioCheck = false;
				} else {
					// 라디오박스 체크여부 담기
					oldRadioCheck = newRadioCheck;
				};

				// 체크한 radio ID 담기
				oldRadioId = newRadioId;

			});

		});


		//엑셀다운로드
		function fnDownloadExcel() {

			var param = {
				"s_excel_down_type1"	: $M.getValue("excel_down_type_1"),
				"s_excel_down_type2"	: $M.getValue("excel_down_type_2"),
				"s_excel_down_type3"	: $M.getValue("excel_down_type_3"),
				"s_excel_down_type4"	: $M.getValue("excel_down_type_4"),
				"s_excel_down_type5"	: $M.getValue("excel_down_type_5"),
				"s_excel_down_type6"	: $M.getValue("excel_down_type_6"),
				"s_maker_cd"			: $M.getValue("s_maker_cd"),
				"s_part_production_cd"	: $M.getValue("s_part_production_cd"),
				"s_part_no_st"			: $M.getValue("s_part_no_st"),
				"s_part_no_ed"			: $M.getValue("s_part_no_ed"),
				"s_part_group_cd"		: $M.getValue("s_part_group_cd"),
				"s_cust_name"			: $M.getValue("s_cust_name"), // 22.10.13 검색조건에 매입처 추가
				"s_provisionStock"		: $M.getValue("provisionStock"),
				"s_unearned"			: $M.getValue("unearned"),
				"s_longTermStock"		: $M.getValue("longTermStock"),
				"s_nonPart"				: $M.getValue("nonPart"),
				"s_stopSales"			: $M.getValue("stopSales"),
			};
			var msg ="부품자료 다운로드 시 데이터량에 따라 최대 10분정도 소요될 수 있습니다.";
			$M.goNextPageAjaxMsg(msg, this_page + "/download", $M.toGetParam(param), {method : 'GET', timeout : 1800000},
					function(result) {
						if(result.success) {
							destroyGrid();
							createExcelGrid();
							AUIGrid.setGridData("#excelGrid", result.list);

							// 엑셀 내보내기 속성
							var exportProps = {};
							fnExportExcel("#excelGrid", "부품자료다운관리", exportProps);
						}
					}
			);
		}

		// 그리드 초기화
		function destroyGrid() {
			AUIGrid.destroy("#excelGrid");
			auiGrid = null;
		}

		// 입력폼에 부품정보 입력
		function setPartInfoSt(row) {
			$M.setValue("s_part_no_st", row.part_no);
			$M.setValue("s_part_name_st", row.part_name);
		}

		// 입력폼에 부품정보 입력
		function setPartInfoEd(row) {
			$M.setValue("s_part_no_ed", row.part_no);
			$M.setValue("s_part_name_ed", row.part_name);
		}

		// 매입처조회
		function fnSearchClientComm() {
			var param = {
				's_cust_name' : $M.getValue('s_cust_name')
			};
			openSearchClientPanel('setSearchClientInfo', 'comm', $M.toGetParam(param));
		}

		// 매입처 조회 팝업 클릭 후 리턴
		function setSearchClientInfo(row) {
			$M.setValue("s_cust_name", row.cust_name);
		}

		// 그리드생성
		function createExcelGrid() {

			var gridPros = {
				rowIdField : "_$uid",
				editable : false,
				showRowNumColumn : false,
				headerHeight : 40
			};

			var	columnLayout = [];
			// var checkBoxVal	 = $M.getValue("s_excel_down_type");

			// if(checkBoxVal == '') {
				// [기본]
				columnLayout = [

					{headerText: "부품번호", dataField: "part_no", style : "aui-left"},
					{headerText: "부품명", dataField: "part_name", style : "aui-left"},
					{headerText: "부품신번호", dataField: "part_new_no", style : "aui-left"},
					{headerText: "신형번호호환성", dataField: "part_new_exchange_cd", style : "aui-left"},
					{headerText: "부품구번호", dataField: "part_old_no", style : "aui-left"},
					{headerText: "구형번호호환성", dataField: "part_old_exchange_cd", style : "aui-left"},
					{headerText: "현재고", dataField: "curr_year_current_stock", style : "aui-left"},
					{headerText: "평균매입가", dataField: "in_avg_price", style : "aui-left"},
					{headerText: "안전재고", dataField: "part_safe_stock", style : "aui-left"},
					{headerText: "총적정재고수량", dataField: "safe_stock_cnt", style : "aui-left"},
					{headerText: "메이커코드", dataField: "maker_cd", style : "aui-left"},
					{headerText: "생산구분코드", dataField: "part_production_cd", style : "aui-left"},
					{headerText: "관리구분코드 / 관리구분명 ", dataField: "part_mng_cd", style : "aui-left"},
					{headerText: "부품그룹코드 / 부품그룹명", dataField: "part_group_cd", style : "aui-left"},
					{headerText: "수요예측자료 여부", dataField: "dem_fore_yn", style : "aui-left"},
					{headerText: "HOMI관리품 여부", dataField: "homi_yn", style : "aui-left"},
					{headerText: "출하관리품 여부", dataField: "out_mng_yn", style : "aui-left"},
					{headerText: "정비지시서 제외 여부", dataField: "repair_yn", style : "aui-left"},
					{headerText: "주요부품설정 여부", dataField: "major_yn", style : "aui-left"},
					{headerText: "당해출고수량", dataField: "curr_year_tot_out_qty", style : "aui-left"},
					{headerText: "당해출고금액", dataField: "curr_year_tot_out_amt", style : "aui-left"},
					{headerText: "전년출고수량", dataField: "bef_year_tot_out_qty", style : "aui-left"},
					{headerText: "전년출고금액", dataField: "bef_year_tot_out_amt", style : "aui-left"},
					{headerText: "전전년출고수량", dataField: "bef_before_year_tot_out_qty", style : "aui-left"},
					{headerText: "전전년출고금액", dataField: "bef_before_year_tot_out_amt", style : "aui-left"},

				];
				if($("#excel_down_type_1").is(":checked")){ // [매입처1]
					columnLayout.push(
							{headerText: "매입처_매입처1", dataField: "deal_cust_name", style : "aui-left"},
							{headerText: "포장단위_매입처1", dataField: "part_pack_unit", style : "aui-left"},
							{headerText: "발주단위_매입처1", dataField: "order_unit", style : "aui-left"},
							{headerText: "구매리드타임_매입처1", dataField: "part_pur_day_cnt", style : "aui-left"},
							{headerText: "최소LOT_매입처1", dataField: "part_lot", style : "aui-left"},
							{headerText: "서비스%_매입처1", dataField: "service_rate", style : "aui-left"},
							{headerText: "매입처그룹_매입처1", dataField: "com_buy_group_cd", style : "aui-left"},
							{headerText: "입고품질검사_매입처1", dataField: "deal_ware_qual_ass", style : "aui-left"},
							{headerText: "금형관리NO_매입처1", dataField: "deal_mold_cont_no_yn", style : "aui-left"},
							{headerText: "산출구분코드", dataField: "part_output_price_cd", style : "aui-left"},
							{headerText: "산출구분명", dataField: "part_output_price_name", style : "aui-left"},
							{headerText: "LIST PRICE_매입처1", dataField: "list_price", style : "aui-left"},
							{headerText: "NET PRICE_매입처1", dataField: "net_price", style : "aui-left"},
							{headerText: "SPECIAL_매입처1", dataField: "special_price", style : "aui-left"},
							{headerText: "입고단가_매입처1", dataField: "in_stock_price", style : "aui-left"},
							{headerText: "VIP판매가_매입처1", dataField: "vip_price", style : "aui-left"},
							{headerText: "전략가", dataField: "strategy_price", style : "aui-left"},
							{headerText: "일반판매가", dataField: "cust_price", style : "aui-left"},
							// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
							// {headerText: "대리점가", dataField: "mng_agency_price", style : "aui-left"},
							{headerText: "위탁판매점가", dataField: "mng_agency_price", style : "aui-left"},
							{headerText: "최종 VIP판매가", dataField: "vip_sale_price", style : "aui-left"},
							{headerText: "최종 일반판매가", dataField: "sale_price", style : "aui-left"},
							{headerText: "당해입고수량_매입처1", dataField: "curr_year_tot_in_qty", style : "aui-left"},
							{headerText: "당해입고금액_매입처1", dataField: "curr_year_tot_in_amt", style : "aui-left"},
							{headerText: "전년입고수량_매입처1", dataField: "bef_year_tot_in_qty", style : "aui-left"},
							{headerText: "전년입고금액_매입처1", dataField: "bef_year_tot_in_amt", style : "aui-left"},
							{headerText: "전전년입고수량_매입처1", dataField: "bef_before_year_tot_in_qty", style : "aui-left"},
							{headerText: "전전년입고금액_매입처1", dataField: "bef_before_year_tot_in_amt", style : "aui-left"},
					)
				}
				if($("#excel_down_type_2").is(":checked")){ //[매입처2]
					columnLayout.push(
							{headerText: "매입처_매입처2", dataField: "deal_cust_name2", style : "aui-left"},
							{headerText: "포장단위_매입처2", dataField: "part_pack_unit2", style : "aui-left"},
							{headerText: "발주단위_매입처2", dataField: "order_unit2", style : "aui-left"},
							{headerText: "구매리드타임_매입처2", dataField: "part_pur_day_cnt2", style : "aui-left"},
							{headerText: "최소LOT_매입처2", dataField: "part_lot2", style : "aui-left"},
							{headerText: "서비스%_매입처2", dataField: "service_rate2", style : "aui-left"},
							{headerText: "매입처그룹_매입처2", dataField: "com_buy_group_cd2", style : "aui-left"},
							{headerText: "입고품질검사_매입처2", dataField: "deal_ware_qual_ass2", style : "aui-left"},
							{headerText: "금형관리NO_매입처2", dataField: "deal_mold_cont_no2_yn", style : "aui-left"},
							{headerText: "산출구분코드", dataField: "part_output_price_cd", style : "aui-left"},
							{headerText: "산출구분명", dataField: "part_output_price_name", style : "aui-left"},
							{headerText: "LIST PRICE_매입처2", dataField: "list_price2", style : "aui-left"},
							{headerText: "NET PRICE_매입처2", dataField: "net_price2", style : "aui-left"},
							{headerText: "SPECIAL_매입처2", dataField: "special_price2", style : "aui-left"},
							{headerText: "입고단가_매입처2", dataField: "in_stock_price2", style : "aui-left"},
							{headerText: "VIP판매가_매입처2", dataField: "vip_price2", style : "aui-left"},
							{headerText: "전략가", dataField: "strategy_price", style : "aui-left"},
							{headerText: "일반판매가", dataField: "cust_price", style : "aui-left"},
							// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
							// {headerText: "대리점가", dataField: "mng_agency_price", style : "aui-left"},
							{headerText: "위탁판매점가", dataField: "mng_agency_price", style : "aui-left"},
							{headerText: "최종 VIP판매가", dataField: "vip_sale_price", style : "aui-left"},
							{headerText: "최종 일반판매가", dataField: "sale_price", style : "aui-left"},
							{headerText: "당해입고수량_매입처2", dataField: "curr_year_tot_in_qty", style : "aui-left"},
							{headerText: "당해입고금액_매입처2", dataField: "curr_year_tot_in_amt", style : "aui-left"},
							{headerText: "전년입고수량_매입처2", dataField: "bef_year_tot_in_qty", style : "aui-left"},
							{headerText: "전년입고금액_매입처2", dataField: "bef_year_tot_in_amt", style : "aui-left"},
							{headerText: "전전년입고수량_매입처2", dataField: "bef_before_year_tot_in_qty", style : "aui-left"},
							{headerText: "전전년입고금액_매입처2", dataField: "bef_before_year_tot_in_amt", style : "aui-left"},
					)
				}
				if($("#excel_down_type_3").is(":checked")){//[마스터]
					columnLayout.push(
							{headerText: "수요예측번호", dataField: "dem_fore_no", style : "aui-left"},
							{headerText: "발주수량", dataField: "order_qty", style : "aui-left"},
							{headerText: "안전재고2", dataField: "part_safe_stock2", style : "aui-left"},
							{headerText: "최초등록일", dataField: "reg_dt", style : "aui-left"},
							{headerText: "매출정지일", dataField: "sale_stop_dt", style : "aui-left"},
							{headerText: "최종매입일", dataField: "last_in_dt", style : "aui-left"},
							{headerText: "최종매입가", dataField: "part_buy_price", style : "aui-left"},
							{headerText: "원산지", dataField: "part_country_cd", style : "aui-left"},
							{headerText: "호환모델", dataField: "part_model", style : "aui-left"},
					)
				}
				if($("#excel_down_type_4").is(":checked")){//[수출가격]
					columnLayout.push(
							{headerText: "수출적용환율", dataField: "apply_er_rate", style : "aui-left"},
							{headerText: "수출원가적용율", dataField: "cost_apply_rate", style : "aui-left"},
							{headerText: "수출적용원가", dataField: "cost_price", style : "aui-left"},
							{headerText: "수출가", dataField: "fob_export_price", style : "aui-left"},
					)
				}
			if($("#excel_down_type_5").is(":checked")){//[HOMI]
				for (var i = 0; i < homiList.length; ++i) {
					console.log(homiList[i].code);
					var obj = {
							headerText: homiList[i].code_name + "HOMI",
							dataField: "warehouse_" + homiList[i].code,
							style : "aui-left"
						}
					columnLayout.push(obj);
				}
			}
			if($("#excel_down_type_6").is(":checked")){//[입출고]
				columnLayout.push(
						{headerText: "3년전출고수량", dataField: "bef_year3_tot_out_qty", style : "aui-left"},
						{headerText: "3년전출고금액", dataField: "bef_year3_tot_out_prcie", style : "aui-left"},
						{headerText: "4년전출고수량", dataField: "bef_year4_tot_out_qty", style : "aui-left"},
						{headerText: "4년전출고금액", dataField: "bef_year4_tot_out_prcie", style : "aui-left"},
						{headerText: "5년전출고수량", dataField: "bef_year5_tot_out_qty", style : "aui-left"},
						{headerText: "5년전출고금액", dataField: "bef_year5_tot_out_prcie", style : "aui-left"},
						{headerText: "당해 01월출고", dataField: "curr_year_out_qty_01", style : "aui-left"},
						{headerText: "당해 02월출고", dataField: "curr_year_out_qty_02", style : "aui-left"},
						{headerText: "당해 03월출고", dataField: "curr_year_out_qty_03", style : "aui-left"},
						{headerText: "당해 04월출고", dataField: "curr_year_out_qty_04", style : "aui-left"},
						{headerText: "당해 05월출고", dataField: "curr_year_out_qty_05", style : "aui-left"},
						{headerText: "당해 06월출고", dataField: "curr_year_out_qty_06", style : "aui-left"},
						{headerText: "당해 07월출고", dataField: "curr_year_out_qty_07", style : "aui-left"},
						{headerText: "당해 08월출고", dataField: "curr_year_out_qty_08", style : "aui-left"},
						{headerText: "당해 09월출고", dataField: "curr_year_out_qty_09", style : "aui-left"},
						{headerText: "당해 10월출고", dataField: "curr_year_out_qty_10", style : "aui-left"},
						{headerText: "당해 11월출고", dataField: "curr_year_out_qty_11", style : "aui-left"},
						{headerText: "당해 12월출고", dataField: "curr_year_out_qty_12", style : "aui-left"},
				)
			}
			/*} else if(checkBoxVal == 'PRICE') {
				// [가격]
				columnLayout = [

					{headerText: "부품번호", dataField: "part_no", style : "aui-left"},
					{headerText: "부품명", dataField: "part_name", style : "aui-left"},
					{headerText: "부품신번호", dataField: "part_new_no", style : "aui-left"},
					{headerText: "부품구번호", dataField: "part_old_no", style : "aui-left"},
					{headerText: "현재고", dataField: "curr_year_current_stock", style : "aui-left"},
					{headerText: "안전재고", dataField: "part_safe_stock", style : "aui-left"},
					{headerText: "총적정재고수량", dataField: "safe_stock_cnt", style : "aui-left"},
					{headerText: "메이커코드", dataField: "maker_cd", style : "aui-left"},
					{headerText: "매입처명", dataField: "deal_cust_name", style : "aui-left"},
					{headerText: "생산구분코드", dataField: "part_production_cd", style : "aui-left"},
					{headerText: "관리구분코드 / 관리구분명 ", dataField: "part_mng_cd", style : "aui-left"},
					{headerText: "산출구분코드", dataField: "part_output_price_cd", style : "aui-left"},
					{headerText: "실사구분코드", dataField: "part_real_check_cd", style : "aui-left"},
					{headerText: "부품그룹코드 / 부품그룹명", dataField: "part_group_cd", style : "aui-left"},
					{headerText: "수요예측자료 여부", dataField: "dem_fore_yn", style : "aui-left"},
					{headerText: "HOMI관리품 여부", dataField: "homi_yn", style : "aui-left"},
					{headerText: "출하관리품 여부", dataField: "out_mng_yn", style : "aui-left"},
					{headerText: "정비지시서 제외 여부", dataField: "repair_yn", style : "aui-left"},
					{headerText: "당해출고", dataField: "curr_year_tot_out_qty", style : "aui-left"},
					{headerText: "전년출고", dataField: "bef_year_tot_out_qty", style : "aui-left"},
					{headerText: "전전년출고", dataField: "bef_before_year_tot_out_qty", style : "aui-left"},
					{headerText: "신형번호호환성", dataField: "part_new_exchange_cd", style : "aui-left"},
					{headerText: "구형번호호환성", dataField: "part_old_exchange_cd", style : "aui-left"},
					{headerText: "단가변경일", dataField: "price_date", style : "aui-left"},
					{headerText: "LIST PRICE", dataField: "list_price", style : "aui-left"},
					{headerText: "NET PRICE", dataField: "net_price", style : "aui-left"},
					{headerText: "SPECIAL", dataField: "special_price", style : "aui-left"},
					{headerText: "입고단가", dataField: "in_stock_price", style : "aui-left"},
					{headerText: "vip판매가", dataField: "vip_price", style : "aui-left"},
					{headerText: "전략가", dataField: "strategy_price", style : "aui-left"},
					{headerText: "일반판매가", dataField: "cust_price", style : "aui-left"},
					{headerText: "대리점가", dataField: "mng_agency_price", style : "aui-left"},
					{headerText: "평균매입가", dataField: "part_avg_price", style : "aui-left"},
					{headerText: "최종 vip판매가", dataField: "vip_sale_price", style : "aui-left"},
					{headerText: "최종 일반판매가", dataField: "sale_price", style : "aui-left"},

				];
			} else if(checkBoxVal == 'PURCHASE') {
				// [매입]
				columnLayout = [

					{headerText: "부품번호", dataField: "part_no", style : "aui-left"},
					{headerText: "부품명", dataField: "part_name", style : "aui-left"},
					{headerText: "부품신번호", dataField: "part_new_no", style : "aui-left"},
					{headerText: "부품구번호", dataField: "part_old_no", style : "aui-left"},
					{headerText: "현재고", dataField: "curr_year_current_stock", style : "aui-left"},
					{headerText: "안전재고", dataField: "part_safe_stock", style : "aui-left"},
					{headerText: "총적정재고수량", dataField: "safe_stock_cnt", style : "aui-left"},
					{headerText: "메이커코드", dataField: "maker_cd", style : "aui-left"},
					{headerText: "매입처명", dataField: "deal_cust_name", style : "aui-left"},
					{headerText: "생산구분코드", dataField: "part_production_cd", style : "aui-left"},
					{headerText: "관리구분코드 / 관리구분명 ", dataField: "part_mng_cd", style : "aui-left"},
					{headerText: "산출구분코드", dataField: "part_output_price_cd", style : "aui-left"},
					{headerText: "실사구분코드", dataField: "part_real_check_cd", style : "aui-left"},
					{headerText: "부품그룹코드 / 부품그룹명", dataField: "part_group_cd", style : "aui-left"},
					{headerText: "수요예측자료 여부", dataField: "dem_fore_yn", style : "aui-left"},
					{headerText: "HOMI관리품 여부", dataField: "homi_yn", style : "aui-left"},
					{headerText: "출하관리품 여부", dataField: "out_mng_yn", style : "aui-left"},
					{headerText: "정비지시서 제외 여부", dataField: "repair_yn", style : "aui-left"},
					{headerText: "당해출고", dataField: "curr_year_tot_out_qty", style : "aui-left"},
					{headerText: "전년출고", dataField: "bef_year_tot_out_qty", style : "aui-left"},
					{headerText: "전전년출고", dataField: "bef_before_year_tot_out_qty", style : "aui-left"},
					{headerText: "신형번호호환성", dataField: "part_new_exchange_cd", style : "aui-left"},
					{headerText: "구형번호호환성", dataField: "part_old_exchange_cd", style : "aui-left"},
					{headerText: "포장단위", dataField: "part_pack_unit", style : "aui-left"},
					{headerText: "중량", dataField: "part_weight_kg", style : "aui-left"},
					{headerText: "발주단위", dataField: "order_unit", style : "aui-left"},
					{headerText: "구매일수(구매리드타임)", dataField: "part_pur_day_cnt", style : "aui-left"},
					{headerText: "LOT사이즈(최소LOT)", dataField: "part_lot", style : "aui-left"},
					{headerText: "서비스%", dataField: "service_rate", style : "aui-left"},
					{headerText: "매입처그룹코드", dataField: "com_buy_group_cd", style : "aui-left"},
					{headerText: "매입처2", dataField: "deal_cust_no2", style : "aui-left"},
					{headerText: "입고품질검사", dataField: "deal_ware_qual_ass", style : "aui-left"},
					{headerText: "금형관리번호여부", dataField: "deal_mold_cont_no_yn", style : "aui-left"},
					{headerText: "도면보유여부", dataField: "deal_floor_plan_yn", style : "aui-left"},

				];
			} else if(checkBoxVal == 'MASTER') {
				// [마스터]
				columnLayout = [

					{headerText: "부품번호", dataField: "part_no", style : "aui-left"},
					{headerText: "부품명", dataField: "part_name", style : "aui-left"},
					{headerText: "부품신번호", dataField: "part_new_no", style : "aui-left"},
					{headerText: "부품구번호", dataField: "part_old_no", style : "aui-left"},
					{headerText: "현재고", dataField: "curr_year_current_stock", style : "aui-left"},
					{headerText: "안전재고", dataField: "part_safe_stock", style : "aui-left"},
					{headerText: "총적정재고수량", dataField: "safe_stock_cnt", style : "aui-left"},
					{headerText: "메이커코드", dataField: "maker_cd", style : "aui-left"},
					{headerText: "매입처명", dataField: "deal_cust_name", style : "aui-left"},
					{headerText: "생산구분코드", dataField: "part_production_cd", style : "aui-left"},
					{headerText: "관리구분코드 / 관리구분명 ", dataField: "part_mng_cd", style : "aui-left"},
					{headerText: "산출구분코드", dataField: "part_output_price_cd", style : "aui-left"},
					{headerText: "실사구분코드", dataField: "part_real_check_cd", style : "aui-left"},
					{headerText: "부품그룹코드 / 부품그룹명", dataField: "part_group_cd", style : "aui-left"},
					{headerText: "수요예측자료 여부", dataField: "dem_fore_yn", style : "aui-left"},
					{headerText: "HOMI관리품 여부", dataField: "homi_yn", style : "aui-left"},
					{headerText: "출하관리품 여부", dataField: "out_mng_yn", style : "aui-left"},
					{headerText: "정비지시서 제외 여부", dataField: "repair_yn", style : "aui-left"},
					{headerText: "당해출고", dataField: "curr_year_tot_out_qty", style : "aui-left"},
					{headerText: "전년출고", dataField: "bef_year_tot_out_qty", style : "aui-left"},
					{headerText: "전전년출고", dataField: "bef_before_year_tot_out_qty", style : "aui-left"},
					{headerText: "신형번호호환성", dataField: "part_new_exchange_cd", style : "aui-left"},
					{headerText: "구형번호호환성", dataField: "part_old_exchange_cd", style : "aui-left"},
					{headerText: "포장단위", dataField: "part_pack_unit", style : "aui-left"},
					{headerText: "중량", dataField: "part_weight_kg", style : "aui-left"},
					{headerText: "발주단위", dataField: "order_unit", style : "aui-left"},
					{headerText: "구매일수(구매리드타임)", dataField: "part_pur_day_cnt", style : "aui-left"},
					{headerText: "LOT사이즈(최소LOT)", dataField: "part_lot", style : "aui-left"},
					{headerText: "서비스%", dataField: "service_rate", style : "aui-left"},
					{headerText: "매입처그룹코드", dataField: "com_buy_group_cd", style : "aui-left"},
					{headerText: "매입처2", dataField: "deal_cust_no2", style : "aui-left"},
					{headerText: "입고품질검사", dataField: "deal_ware_qual_ass", style : "aui-left"},
					{headerText: "금형관리번호여부", dataField: "deal_mold_cont_no_yn", style : "aui-left"},
					{headerText: "도면보유여부", dataField: "deal_floor_plan_yn", style : "aui-left"},
					{headerText: "수요예측번호", dataField: "dem_fore_no", style : "aui-left"},
					{headerText: "발주수량", dataField: "order_qty", style : "aui-left"},
					{headerText: "안전재고2", dataField: "part_safe_stock2", style : "aui-left"},
					{headerText: "당해 출고금액", dataField: "curr_year_tot_out_price", style : "aui-left"},
					{headerText: "전년 출고금액", dataField: "bef1_year_tot_out_price", style : "aui-left"},
					{headerText: "최초등록일자", dataField: "reg_dt", style : "aui-left"},
					{headerText: "매출정지일자", dataField: "sale_stop_dt", style : "aui-left"},
					{headerText: "최종매입일자", dataField: "last_in_dt", style : "aui-left"},
					{headerText: "최종매입가격", dataField: "part_buy_price", style : "aui-left"},
					{headerText: "원산지코드", dataField: "part_country_cd", style : "aui-left"},
					{headerText: "호환모델", dataField: "part_model", style : "aui-left"},
					{headerText: "연간입고수량", dataField: "curr_year_tot_in_qty", style : "aui-left"},
					{headerText: "연간출고수량", dataField: "curr_year_tot_out_qty", style : "aui-left"},
					{headerText: "수출적용환율", dataField: "apply_er_rate", style : "aui-left"},
					{headerText: "수출원가적용율", dataField: "cost_apply_rate", style : "aui-left"},
					{headerText: "수출적용원가", dataField: "cost_price", style : "aui-left"},
					{headerText: "FOB수출가", dataField: "fob_export_price", style : "aui-left"},

				];
			} else if(checkBoxVal == 'HOMI') {
				// [HOMI]
				columnLayout = [

					{headerText: "부품번호", dataField: "part_no", style : "aui-left"},
					{headerText: "부품명", dataField: "part_name", style : "aui-left"},
					{headerText: "부품신번호", dataField: "part_new_no", style : "aui-left"},
					{headerText: "부품구번호", dataField: "part_old_no", style : "aui-left"},
					{headerText: "현재고", dataField: "curr_year_current_stock", style : "aui-left"},
					{headerText: "안전재고", dataField: "part_safe_stock", style : "aui-left"},
					{headerText: "총적정재고수량", dataField: "safe_stock_cnt", style : "aui-left"},
					{headerText: "메이커코드", dataField: "maker_cd", style : "aui-left"},
					{headerText: "매입처명", dataField: "deal_cust_name", style : "aui-left"},
					{headerText: "생산구분코드", dataField: "part_production_cd", style : "aui-left"},
					{headerText: "관리구분코드 / 관리구분명 ", dataField: "part_mng_cd", style : "aui-left"},
					{headerText: "산출구분코드", dataField: "part_output_price_cd", style : "aui-left"},
					{headerText: "실사구분코드", dataField: "part_real_check_cd", style : "aui-left"},
					{headerText: "부품그룹코드 / 부품그룹명", dataField: "part_group_cd", style : "aui-left"},
					{headerText: "수요예측자료 여부", dataField: "dem_fore_yn", style : "aui-left"},
					{headerText: "HOMI관리품 여부", dataField: "homi_yn", style : "aui-left"},
					{headerText: "출하관리품 여부", dataField: "out_mng_yn", style : "aui-left"},
					{headerText: "정비지시서 제외 여부", dataField: "repair_yn", style : "aui-left"},
					{headerText: "당해출고", dataField: "curr_year_tot_out_qty", style : "aui-left"},
					{headerText: "전년출고", dataField: "bef_year_tot_out_qty", style : "aui-left"},
					{headerText: "전전년출고", dataField: "bef_before_year_tot_out_qty", style : "aui-left"},
					{headerText: "신형번호호환성", dataField: "part_new_exchange_cd", style : "aui-left"},
					{headerText: "구형번호호환성", dataField: "part_old_exchange_cd", style : "aui-left"},
				];

				for (var i = 0; i < homiList.length; ++i) {
					console.log(homiList[i].code);
					var obj = {
						headerText: homiList[i].code_name + "HOMI적정재고",
						dataField: "warehouse_" + homiList[i].code,
						style : "aui-left"
					}
					columnLayout.push(obj);
				}
			} else if(checkBoxVal == 'INOUT') {
				// [입출고]
				columnLayout = [

					{headerText: "부품번호", dataField: "part_no", style : "aui-left"},
					{headerText: "부품명", dataField: "part_name", style : "aui-left"},
					{headerText: "부품신번호", dataField: "part_new_no", style : "aui-left"},
					{headerText: "부품구번호", dataField: "part_old_no", style : "aui-left"},
					{headerText: "현재고", dataField: "curr_year_current_stock", style : "aui-left"},
					{headerText: "안전재고", dataField: "part_safe_stock", style : "aui-left"},
					{headerText: "총적정재고수량", dataField: "safe_stock_cnt", style : "aui-left"},
					{headerText: "메이커코드", dataField: "maker_cd", style : "aui-left"},
					{headerText: "매입처명", dataField: "deal_cust_name", style : "aui-left"},
					{headerText: "생산구분코드", dataField: "part_production_cd", style : "aui-left"},
					{headerText: "관리구분코드 / 관리구분명 ", dataField: "part_mng_cd", style : "aui-left"},
					{headerText: "산출구분코드", dataField: "part_output_price_cd", style : "aui-left"},
					{headerText: "실사구분코드", dataField: "part_real_check_cd", style : "aui-left"},
					{headerText: "부품그룹코드 / 부품그룹명", dataField: "part_group_cd", style : "aui-left"},
					{headerText: "수요예측자료 여부", dataField: "dem_fore_yn", style : "aui-left"},
					{headerText: "HOMI관리품 여부", dataField: "homi_yn", style : "aui-left"},
					{headerText: "출하관리품 여부", dataField: "out_mng_yn", style : "aui-left"},
					{headerText: "정비지시서 제외 여부", dataField: "repair_yn", style : "aui-left"},
					{headerText: "당해출고", dataField: "curr_year_tot_out_qty", style : "aui-left"},
					{headerText: "전년출고", dataField: "bef_year_tot_out_qty", style : "aui-left"},
					{headerText: "전전년출고", dataField: "bef_before_year_tot_out_qty", style : "aui-left"},
					{headerText: "신형번호호환성", dataField: "part_new_exchange_cd", style : "aui-left"},
					{headerText: "구형번호호환성", dataField: "part_old_exchange_cd", style : "aui-left"},
					{headerText: "3년전출고수량", dataField: "bef_year3_tot_out_qty", style : "aui-left"},
					{headerText: "3년전출고금액", dataField: "bef_year3_tot_out_prcie", style : "aui-left"},
					{headerText: "4년전출고수량", dataField: "bef_year4_tot_out_qty", style : "aui-left"},
					{headerText: "4년전출고금액", dataField: "bef_year4_tot_out_prcie", style : "aui-left"},
					{headerText: "5년전출고수량", dataField: "bef_year5_tot_out_qty", style : "aui-left"},
					{headerText: "5년전출고금액", dataField: "bef_year5_tot_out_prcie", style : "aui-left"},
					{headerText: "당해 01월출고", dataField: "curr_year_out_qty_01", style : "aui-left"},
					{headerText: "당해 02월출고", dataField: "curr_year_out_qty_02", style : "aui-left"},
					{headerText: "당해 03월출고", dataField: "curr_year_out_qty_03", style : "aui-left"},
					{headerText: "당해 04월출고", dataField: "curr_year_out_qty_04", style : "aui-left"},
					{headerText: "당해 05월출고", dataField: "curr_year_out_qty_05", style : "aui-left"},
					{headerText: "당해 06월출고", dataField: "curr_year_out_qty_06", style : "aui-left"},
					{headerText: "당해 07월출고", dataField: "curr_year_out_qty_07", style : "aui-left"},
					{headerText: "당해 08월출고", dataField: "curr_year_out_qty_08", style : "aui-left"},
					{headerText: "당해 09월출고", dataField: "curr_year_out_qty_09", style : "aui-left"},
					{headerText: "당해 10월출고", dataField: "curr_year_out_qty_10", style : "aui-left"},
					{headerText: "당해 11월출고", dataField: "curr_year_out_qty_11", style : "aui-left"},
					{headerText: "당해 12월출고", dataField: "curr_year_out_qty_12", style : "aui-left"},

				];
			}*/

			excelGrid = AUIGrid.create("#excelGrid", columnLayout, gridPros);
		}


		// 그리드생성
		function createAUIGrid1() {
			var gridPros = {
				rowIdField : "_$uid",
				editable : false,
				showRowNumColumn : false,
				showHeader: false // header표시 여부
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
					headerText: "내용",
					dataField: "1",
					style : "aui-left"
				}
			];

			var gridData = [
				{
					"1" : "부품번호",
				},
				{
					"1" : "품명",
				},
				{
					"1" : "신형번호",
				},
				{
					"1" : "신형번호호환성",
				},
				{
					"1" : "구형번호",
				},
				{
					"1" : "구형번호호환성",
				},
				{
					"1" : "현재고",
				},
				{
					"1" : "평균매입가",
				},
				{
					"1" : "안전재고",
				},
				{
					"1" : "총적정재고수량",
				},
				{
					"1" : "메이커",
				},
				{
					"1" : "생산구분",
				},
				{
					"1" : "관리구분",
				},
				{
					"1" : "관리구분명",
				},
				{
					"1" : "부품그룹",
				},
				{
					"1" : "그룹명",
				},
				{
					"1" : "수요예측자료 여부",
				},
				{
					"1" : "HOMI관리품 여부",
				},
				{
					"1" : "출하관리품 여부",
				},
				{
					"1" : "정비지시서 제외 여부",
				},
				{
					"1" : "주요부품설정 여부",
				},
				{
					"1" : "당해출고 수량",
				},
				{
					"1" : "당해출고 금액",
				},
				{
					"1" : "전년출고 수량",
				},
				{
					"1" : "전년출고 금액",
				},
				{
					"1" : "전전년출고 수량",
				},
				{
					"1" : "전전년출고 금액",
				},
			];

			// 그리드 출력
			auiGrid = AUIGrid.create("#auiGrid1", columnLayout, gridPros);
			// 그리드 갱신
			// AUIGrid.setGridData(auiGrid, []);
			AUIGrid.setGridData(auiGrid, gridData);
		}

		// 그리드생성
		function createAUIGrid2() {
			var gridPros = {
				rowIdField : "_$uid",
				editable : false,
				showRowNumColumn : false,
				showHeader: false // header표시 여부
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
					headerText: "내용",
					dataField: "1",
					style : "aui-left"
				}
			];

			var gridData = [
				{
					"1" : "매입처_매입처1",
				},
				{
					"1" : "포장단위_매입처1",
				},
				{
					"1" : "발주단위_매입처1",
				},
				{
					"1" : "구매리드타입_매입처1",
				},
				{
					"1" : "최소LOT_매입처1",
				},
				{
					"1" : "서비스%_매입처1",
				},
				{
					"1" : "매입처그룹_매입처1",
				},
				{
					"1" : "입고품질검사_매입처1",
				},
				{
					"1" : "금형관리NO_매입처1",
				},
				{
					"1" : "산출구분(코드)",
				},
				{
					"1" : "산출구분명",
				},
				{
					"1" : "LIST PRICE_매입처1",
				},
				{
					"1" : "NET PRICE_매입처1",
				},
				{
					"1" : "SPECIAL_매입처1",
				},
				{
					"1" : "입고단가_매입처1",
				},
				{
					"1" : "VIP판매가_매입처1",
				},
				{
					"1" : "전략가",
				},
				{
					"1" : "일반판매가",
				},
				{
					// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
					// "1" : "대리점가",
					"1" : "위탁판매점가",
				},
				{
					"1" : "최종 VIP판매가",
				},
				{
					"1" : "최종일반판매가",
				},
				{
					"1" : "당해입고 수량_매입처1",
				},
				{
					"1" : "당해입고 금액_매입처1",
				},
				{
					"1" : "전년입고 수량_매입처1",
				},
				{
					"1" : "전년입고 금액_매입처1",
				},
				{
					"1" : "전전년입고 수량_매입처1",
				},
				{
					"1" : "전전년입고 금액_매입처1",
				},

			];

			// 그리드 출력
			auiGrid = AUIGrid.create("#auiGrid2", columnLayout, gridPros);
			// 그리드 갱신
			// AUIGrid.setGridData(auiGrid, []);
			AUIGrid.setGridData(auiGrid, gridData);
		}

		// 그리드생성
		function createAUIGrid3() {
			var gridPros = {
				rowIdField : "_$uid",
				editable : false,
				showRowNumColumn : false,
				showHeader: false // header표시 여부
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
					headerText: "내용",
					dataField: "1",
					style : "aui-left"
				}
			];

			var gridData = [
				{
					"1" : "매입처_매입처2",
				},
				{
					"1" : "포장단위_매입처2",
				},
				{
					"1" : "발주단위_매입처2",
				},
				{
					"1" : "구매리드타입_매입처2",
				},
				{
					"1" : "최소LOT_매입처2",
				},
				{
					"1" : "서비스%_매입처2",
				},
				{
					"1" : "매입처그룹_매입처2",
				},
				{
					"1" : "입고품질검사_매입처2",
				},
				{
					"1" : "금형관리NO_매입처2",
				},
				{
					"1" : "산출구분(코드)",
				},
				{
					"1" : "산출구분명",
				},
				{
					"1" : "LIST PRICE_매입처2",
				},
				{
					"1" : "NET PRICE_매입처2",
				},
				{
					"1" : "SPECIAL_매입처2",
				},
				{
					"1" : "입고단가_매입처2",
				},
				{
					"1" : "VIP판매가_매입처2",
				},
				{
					"1" : "전략가",
				},
				{
					"1" : "일반판매가",
				},
				{
					// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
					// "1" : "대리점가",
					"1" : "위탁판매점가",
				},
				{
					"1" : "최종 VIP판매가",
				},
				{
					"1" : "최종일반판매가",
				},
				{
					"1" : "당해입고 수량_매입처2",
				},
				{
					"1" : "당해입고 금액_매입처2",
				},
				{
					"1" : "전년입고 수량_매입처2",
				},
				{
					"1" : "전년입고 금액_매입처2",
				},
				{
					"1" : "전전년입고 수량_매입처2",
				},
				{
					"1" : "전전년입고 금액_매입처2",
				},
			];

			// 그리드 출력
			auiGrid = AUIGrid.create("#auiGrid3", columnLayout, gridPros);
			// 그리드 갱신
			// AUIGrid.setGridData(auiGrid, []);
			AUIGrid.setGridData(auiGrid, gridData);
		}

		// 그리드생성
		function createAUIGrid4() {
			var gridPros = {
				rowIdField : "_$uid",
				editable : false,
				showRowNumColumn : false,
				showHeader: false, // header표시 여부
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
					headerText: "내용",
					dataField: "1",
					style : "aui-left"
				}
			];

			var gridData = [
				{
					"1" : "수요예측번호",
				},
				{
					"1" : "발주수량",
				},
				{
					"1" : "안전재고2",
				},
				{
					"1" : "최초등록일",
				},
				{
					"1" : "매출정지일",
				},
				{
					"1" : "최종매입일",
				},
				{
					"1" : "최종매입가",
				},
				{
					"1" : "원산지",
				},
				{
					"1" : "호환모델",
				},

			];

			// 그리드 출력
			auiGrid = AUIGrid.create("#auiGrid4", columnLayout, gridPros);
			// 그리드 갱신
			// AUIGrid.setGridData(auiGrid, []);
			AUIGrid.setGridData(auiGrid, gridData);
		}

		// 그리드생성
		function createAUIGrid5() {
			var gridPros = {
				rowIdField : "_$uid",
				editable : false,
				showRowNumColumn : false,
				showHeader: false // header표시 여부
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
					headerText: "내용",
					dataField: "1",
					style : "aui-left"
				}
			];

			var gridData = [
				{
					"1" : "수출적용환율",
				},
				{
					"1" : "수출원가적용율",
				},
				{
					"1" : "수출적용원가",
				},
				{
					"1" : "수출가",
				},

			];

			// 그리드 출력
			auiGrid = AUIGrid.create("#auiGrid5", columnLayout, gridPros);
			// 그리드 갱신
			// AUIGrid.setGridData(auiGrid, []);
			AUIGrid.setGridData(auiGrid, gridData);
		}

		// 그리드생성
		function createAUIGrid6() {
			var gridPros = {
				rowIdField : "_$uid",
				editable : false,
				showRowNumColumn : false,
				showHeader: false // header표시 여부
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
					headerText: "내용",
					dataField: "1",
					style : "aui-left"
				}
			];

			var gridData = [];

			for (var i = 0; i < homiList.length; ++i) {
				var obj = {
					"1" : homiList[i].code_name + " HOMI",
				}

				gridData.push(obj);
			}


			// 그리드 출력
			auiGrid = AUIGrid.create("#auiGrid6", columnLayout, gridPros);
			// 그리드 갱신
			// AUIGrid.setGridData(auiGrid, []);
			AUIGrid.setGridData(auiGrid, gridData);
		}

		// 그리드생성
		function createAUIGrid7() {
			var gridPros = {
				rowIdField : "_$uid",
				editable : false,
				showRowNumColumn : false,
				showHeader: false // header표시 여부
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
					headerText: "내용",
					dataField: "1",
					style : "aui-left"
				}
			];

			var gridData = [
				{
					"1" : "3년전 출고수량",
				},
				{
					"1" : "3년전 출고금액",
				},
				{
					"1" : "4년전 출고수량",
				},
				{
					"1" : "4년전 출고금액",
				},
				{
					"1" : "5년전 출고수량",
				},
				{
					"1" : "5년전 출고금액",
				},
				{
					"1" : "당해 01월",
				},
				{
					"1" : "당해 02월",
				},
				{
					"1" : "당해 03월",
				},
				{
					"1" : "당해 04월",
				},
				{
					"1" : "당해 05월",
				},
				{
					"1" : "당해 06월",
				},
				{
					"1" : "당해 07월",
				},
				{
					"1" : "당해 08월",
				},
				{
					"1" : "당해 09월",
				},
				{
					"1" : "당해 10월",
				},
				{
					"1" : "당해 11월",
				},
				{
					"1" : "당해 12월",
				},
			];

			// 그리드 출력
			auiGrid = AUIGrid.create("#auiGrid7", columnLayout, gridPros);
			// 그리드 갱신
			// AUIGrid.setGridData(auiGrid, []);
			AUIGrid.setGridData(auiGrid, gridData);
		}


	</script>
</head>
<body>
<form id="main_form" name="main_form">
	<div class="layout-box">
		<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
				<!-- 메인 타이틀 -->
				<div class="main-title">
					<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
				</div>
				<!-- /메인 타이틀 -->
				<div class="contents">
					<!-- 검색영역 -->
					<div class="search-wrap">
						<table class="table table-fixed">
							<colgroup>
								<col width="50px">
								<col width="170px">
								<col width="65px">
								<col width="260px">
								<col width="65px">
								<col width="200px">
								<col width="65px">
								<col width="50px">
								<col width="100px">
								<col width="">
							</colgroup>
							<tbody>
							<tr>
								<th>메이커</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-6">
											<select class="form-control" id="s_maker_cd" name="s_maker_cd"  >
												<option value="">- 전체 -</option>
												<c:forEach items="${makerList}" var="item" varStatus="status">
													<option value="${item.code_value}">${item.code_name}</option>
												</c:forEach>
												<%-- 													<c:forEach var="item" items="${codeMap['MAKER']}"> --%>
												<%-- 															<option value="${item.code_value}">${item.code_name}</option>										 --%>
												<%-- 													</c:forEach>	 --%>
											</select>
										</div>
										<div class="col-5">
											<select class="form-control" id="s_part_production_cd" name="s_part_production_cd"  >
												<option value="">- 전체 -</option>
												<c:forEach var="item" items="${codeMap['PART_PRODUCTION']}">
													<option value="${item.code_value}">${item.code_name}</option>
												</c:forEach>
											</select>
										</div>
									</div>
								</td>
								<th>부품코드</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col" style="width: 120px;">
											<div class="input-group">
												<input type="text" class="form-control border-right-0" id="s_part_no_st" name="s_part_no_st">
												<input type="hidden" class="form-control border-right-0" id="s_part_name_st" name="s_part_name_st">
												<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchPartPanel('setPartInfoSt', 'N');"><i class="material-iconssearch"></i></button>
											</div>
										</div>
										<div class="col text-center" style="width: 20px;">
											~
										</div>
										<div class="col" style="width: 120px;">
											<div class="input-group">
												<input type="text" class="form-control border-right-0" id="s_part_no_ed" name="s_part_no_ed">
												<input type="hidden" class="form-control border-right-0" id="s_part_name_ed" name="s_part_name_ed">
												<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchPartPanel('setPartInfoEd', 'N');"><i class="material-iconssearch"></i></button>
											</div>
										</div>
									</div>
								</td>
								<th>분류구분</th>
								<td>
									<div class="form-row inline-pd " style="padding-left : 5px;">
										<input type="text" class="form-control essential-bg" alt="분류구분" required="required" style="width : 200px";
											   id="s_part_group_cd"
											   name="s_part_group_cd"
											   easyui="combogrid"
											   header="Y"
											   easyuiname="partGroupCode"
											   idfield="code_value"
											   textfield="code_name"
											   enter=""
											   multi="N"
										/>
									</div>
								</td>
								<th>포함여부</th>
								<th>매입처</th>
								<td>
									<div class="input-group">
										<input type="text" class="form-control border-right-0" placeholder="" id="s_cust_name" name="s_cust_name" value="">
										<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSearchClientComm();"><i class="material-iconssearch"></i></button>
									</div>
								</td>
								<td class="pl15">
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="checkbox" id="provisionStock" name="provisionStock" value="Y">
										<label class="form-check-label" for="provisionStock">충당재고</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="checkbox" id="unearned" name="unearned" value="Y">
										<label class="form-check-label" for="unearned">미수입</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="checkbox" id="longTermStock" name="longTermStock" value="Y">
										<label class="form-check-label" for="longTermStock">장기재고</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="checkbox" id="nonPart" name="nonPart" value="Y">
										<label class="form-check-label" for="nonPart">비부품</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="checkbox" id="stopSales" name="stopSales" value="Y">
										<label class="form-check-label" for="stopSales">매출정지품</label>
									</div>
								</td>
							</tr>
							</tbody>
						</table>
					</div>
					<!-- /검색영역 -->
					<div class="row">
						<!-- 메뉴목록 -->
						<div class="col width200px">
							<div class="title-wrap mt10">
								<h4>기본</h4>
								<div class="btn-group">
									<div class="right">
										<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
									</div>
								</div>
							</div>
							<div id="auiGrid1" style="margin-top: 5px; height: 635px;"></div>
						</div>
						<div class="col width200px">
							<div class="title-wrap mt10">
								<div class="form-check form-check-inline">
<%--									<input class="form-check-input" type="radio" id="excel_down_type_1" name="s_excel_down_type" value="PRICE">--%>
<%--									<label class="form-check-label" for="excel_down_type_1">매입처1</label>--%>
									<input class="form-check-input" type="checkbox" id="excel_down_type_1" name="excel_down_type_1" value="Y">
									<label class="form-check-label" for="excel_down_type_1">매입처1</label>
								</div>
							</div>
							<div id="auiGrid2" style="margin-top: 5px; height: 635px;"></div>
						</div>
						<div class="col width200px">
							<div class="title-wrap mt10">
								<div class="form-check form-check-inline">
<%--									<input class="form-check-input" type="radio" id="excel_down_type_2" name="s_excel_down_type" value="PURCHASE">--%>
<%--									<label class="form-check-label" for="excel_down_type_2">매입처2</label>--%>
									<input class="form-check-input" type="checkbox" id="excel_down_type_2" name="excel_down_type_2"  value="Y">
									<label class="form-check-label" for="excel_down_type_2">매입처2</label>
								</div>
							</div>
							<div id="auiGrid3" style="margin-top: 5px; height: 635px;"></div>
						</div>
						<div class="col width200px">
							<div class="title-wrap mt10">
								<div class="form-check form-check-inline">
<%--									<input class="form-check-input" type="radio" id="excel_down_type_3" name="s_excel_down_type" value="MASTER">--%>
<%--									<label class="form-check-label" for="excel_down_type_3">마스터</label>--%>
									<input class="form-check-input" type="checkbox" id="excel_down_type_3" name="excel_down_type_3" value="Y">
									<label class="form-check-label" for="excel_down_type_3">마스터</label>
								</div>
							</div>
							<div id="auiGrid4" style="margin-top: 5px; height: 245px;"></div>
						</div>
						<div class="col width200px">
							<div class="title-wrap mt10">
								<div class="form-check form-check-inline">
<%--									<input class="form-check-input" type="radio" id="excel_down_type_6" name="s_excel_down_type" value="OUTPRICE">--%>
<%--									<label class="form-check-label" for="excel_down_type_5">수출가격</label>--%>
									<input class="form-check-input" type="checkbox" id="excel_down_type_4" name="excel_down_type_4"  value="Y">
									<label class="form-check-label" for="excel_down_type_4">수출가격</label>
								</div>
							</div>
							<div id="auiGrid5" style="margin-top: 5px; height: 115px;"></div>
						</div>
						<div class="col width200px">
							<div class="title-wrap mt10">
								<div class="form-check form-check-inline">
<%--									<input class="form-check-input" type="radio" id="excel_down_type_4" name="s_excel_down_type" value="HOMI">--%>
<%--									<label class="form-check-label" for="excel_down_type_4">HOMI</label>--%>
									<input class="form-check-input" type="checkbox" id="excel_down_type_5" name="excel_down_type_5" value="Y">
									<label class="form-check-label" for="excel_down_type_5">HOMI</label>
								</div>
							</div>
							<div id="auiGrid6" style="margin-top: 5px; height: 635px;"></div>
						</div>
						<div class="col width200px">
							<div class="title-wrap mt10">
								<div class="form-check form-check-inline">
<%--									<input class="form-check-input" type="radio" id="excel_down_type_5" name="s_excel_down_type" value="INOUT">--%>
<%--									<label class="form-check-label" for="excel_down_type_5">입출고</label>--%>
									<input class="form-check-input" type="checkbox" id="excel_down_type_6" name="excel_down_type_6" value="Y">
									<label class="form-check-label" for="excel_down_type_6">입출고</label>
								</div>
							</div>
							<div id="auiGrid7" style="margin-top: 5px; height: 635px;"></div>
						</div>
						<div id="excelGrid" style="height: 0px; overflow: hidden;"></div>
					</div>
				</div>
			</div>
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
		</div>
		<!-- /contents 전체 영역 -->
	</div>
</form>
</body>
</html>
