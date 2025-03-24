<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 부품통계 > 부품재고현황 > null > null
-- 작성자 : 손광진
-- 최초 작성일 : 2020-09-08 16:18:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var page = 1;
		var moreFlag = "N";
		var isLoading = false;

		var excelGrid;
		var auiGridExcel;

		$(document).ready(function() {
			// 그리드 생성
			createAUIGrid();
			createExcelGrid();
			createAUIGridExcel();
		});

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

		//엑셀다운로드
		function fnDownloadExcel() {
			// console.log(AUIGrid.getGridData(excelGrid).length);
			alert("엑셀은 현재 페이지(" + AUIGrid.getGridData(excelGrid).length + "건)만 다운로드합니다.");

			fnExportExcel(excelGrid, "부품재고현황", "");
		}


		function fnDownload(){
			var msg = $M.getValue("s_year") + "년 " + $M.getValue("s_month") + "월 월말재고자료를 다운로드 하시겠습니까?";
			var param = {
					"s_search_mon" : $M.getValue("s_year") + $M.getValue("s_month").padStart(2, '0')
			};
			 $M.goNextPageAjaxMsg(msg, this_page + "/download", $M.toGetParam(param), {method: 'get', timeout : 60 * 60 * 1000},
	                function (result) {
	                    if (result.success) {
	                        AUIGrid.setGridData(auiGridExcel, result.list);
	                        var exportProps = {};
	                        fnExportExcel(auiGridExcel, "부품월말재고다운로드", exportProps);
	                }
		     });
		}

		function createAUIGridExcel(){
			var gridPros = {
	                // Row번호 표시 여부
	                showRowNumColumn: false
	            };

	            var columnLayout = [
	            {
	                headerText: "부품번호",
	                dataField: "part_no",
	                width: "120",
	                minWidth: "120",
	                style: "aui-center",
	            },
	            {
	                headerText: "부품신번호",
	                dataField: "part_new_no",
	                width: "120",
	                minWidth: "120",
	                style: "aui-center",
	            },
	            {
	                headerText: "부품명",
	                dataField: "part_name",
	                width: "180",
	                minWidth: "180",
	                style: "aui-center",
	            },
	            {
	                headerText: "메이커코드",
	                dataField: "maker_cd",
	                width: "80",
	                minWidth: "80",
	                style: "aui-center",
	            },
	            {
	                headerText: "메이커명",
	                dataField: "code_name",
	                width: "80",
	                minWidth: "80",
	                style: "aui-center",
	            },
	            {
	                headerText: "매입처고객번호",
	                dataField: "deal_cust_no",
	                width: "120",
	                minWidth: "120",
	                style: "aui-center",
	            },
	            {
	                headerText: "매입처명",
	                dataField: "deal_cust_name",
	                width: "160",
	                minWidth: "160",
	                style: "aui-center",
	            },
	            {
	                headerText: "현재고",
	                dataField: "currentqty",
	                width: "80",
	                minWidth: "80",
	                style: "aui-center",
	            },
	            {
	                headerText: "평균매입가",
	                dataField: "avg_in_price",
					dataType : "numeric",
					formatString : "#,##0",
	                width: "120",
	                minWidth: "120",
	                style: "aui-center",
	            },
	            {
	                headerText: "안전재고",
	                dataField: "part_safe_stock",
	                width: "80",
	                minWidth: "80",
	                style: "aui-center",
	            },
	            {
	                headerText: "부품실사구분",
	                dataField: "part_real_check_cd",
	                width: "100",
	                minWidth: "100",
	                style: "aui-center",
	            },
	            {
	                headerText: "부품판매단가계산식",
	                dataField: "part_output_price_name",
	                width: "140",
	                minWidth: "140",
	                style: "aui-center",
	            },
	            {
	                headerText: "부품분류구분",
	                dataField: "part_group_name",
	                width: "200",
	                minWidth: "200",
	                style: "aui-center",
	            },
	            {
	                headerText: "부품생산구분",
	                dataField: "part_production_name",
	                width: "100",
	                minWidth: "100",
	                style: "aui-center",
	            },
	            {
	                headerText: "부품관리구분",
	                dataField: "part_mng_name",
	                width: "100",
	                minWidth: "100",
	                style: "aui-center",
	            },
	            {
	                headerText: "List Price",
	                dataField: "list_price",
					dataType : "numeric",
					formatString : "#,##0.00",
	                width: "120",
	                minWidth: "120",
	                style: "aui-center",
	            },
	            {
	                headerText: "Net Price",
	                dataField: "net_price",
					dataType : "numeric",
					formatString : "#,##0.00",
	                width: "120",
	                minWidth: "120",
	                style: "aui-center",
	            },
	            {
	                headerText: "SPECIAL",
	                dataField: "special_price",
					dataType : "numeric",
					formatString : "#,##0.00",
	                width: "120",
	                minWidth: "120",
	                style: "aui-center",
	            },
	            {
	                headerText: "입고단가",
	                dataField: "in_stock_price",
					dataType : "numeric",
					formatString : "#,##0",
	                width: "120",
	                minWidth: "120",
	                style: "aui-center",
	            },
	            {
	                headerText: "일반판매가",
	                dataField: "cust_price",
					dataType : "numeric",
					formatString : "#,##0",
	                width: "120",
	                minWidth: "120",
	                style: "aui-center",
	            },
	            {
	                headerText: "vip판매가",
	                dataField: "vip판매가",
					dataType : "numeric",
					formatString : "#,##0",
	                width: "120",
	                minWidth: "120",
	                style: "aui-center",
	            },
	            {
	                headerText: "최종vip판매가",
	                dataField: "최종vip판매가",
					dataType : "numeric",
					formatString : "#,##0",
	                width: "120",
	                minWidth: "120",
	                style: "aui-center",
	            },
	            {
	                headerText: "전략가",
	                dataField: "strategy_price",
					dataType : "numeric",
					formatString : "#,##0",
	                width: "120",
	                minWidth: "120",
	                style: "aui-center",
	            },
	            {
					// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
					// headerText: "관리대리점가1",
					headerText: "관리위탁판매점가1",
	                dataField: "mng_agency_price",
					dataType : "numeric",
					formatString : "#,##0",
	                width: "120",
	                minWidth: "120",
	                style: "aui-center",
	            },
	            {
					// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
	                // headerText: "관리대리점가2",
	                headerText: "관리위탁판매점가2",
	                dataField: "mng_agency_price2",
					dataType : "numeric",
					formatString : "#,##0",
	                width: "120",
	                minWidth: "120",
	                style: "aui-center",
	            },
	            {
	                headerText: "최종판매일",
	                dataField: "last_sale_date",
					dataType : "date",
					formatString : "yyyy-mm-dd",
	                width: "100",
	                minWidth: "100",
	                style: "aui-center",
	            },
	            {
	                headerText: "사용개시일",
	                dataField: "use_start_dt",
					dataType : "date",
					formatString : "yyyy-mm-dd",
	                width: "100",
	                minWidth: "100",
	                style: "aui-center",
	            },
	            {
	                headerText: "최종매입일",
	                dataField: "last_in_dt",
					dataType : "date",
					formatString : "yyyy-mm-dd",
	                width: "100",
	                minWidth: "100",
	                style: "aui-center",
	            },
	            {
	                headerText: "입고수량",
	                dataField: "curr_in_qty",
	                width: "120",
	                minWidth: "120",
	                style: "aui-center",
	            },
	            {
	                headerText: "출고수량",
	                dataField: "curr_out_qty",
	                width: "120",
	                minWidth: "120",
	                style: "aui-center",
	            },
	            {
	                headerText: "당해판매금액",
	                dataField: "curr_out_amount",
	                width: "120",
	                minWidth: "120",
	                style: "aui-center",
	            },
	            {
	                headerText: "출고수량합(1년전)",
	                dataField: "pre_out_qty",
	                width: "120",
	                minWidth: "120",
	                style: "aui-center",
	            },
	            {
	                headerText: "출고수량합(2년전)",
	                dataField: "before_pre_out_qty",
	                width: "120",
	                minWidth: "120",
	                style: "aui-center",
	            },
	            {
	                headerText: "당해1월출고수량",
	                dataField: "curr_out_qty01",
	                width: "120",
	                minWidth: "120",
	                style: "aui-center",
	            },
	            {
	                headerText: "당해2월출고수량",
	                dataField: "curr_out_qty02",
	                width: "120",
	                minWidth: "120",
	                style: "aui-center",
	            },
	            {
	                headerText: "당해3월출고수량",
	                dataField: "curr_out_qty03",
	                width: "120",
	                minWidth: "120",
	                style: "aui-center",
	            },
	            {
	                headerText: "당해4월출고수량",
	                dataField: "curr_out_qty04",
	                width: "120",
	                minWidth: "120",
	                style: "aui-center",
	            },
	            {
	                headerText: "당해5월출고수량",
	                dataField: "curr_out_qty05",
	                width: "120",
	                minWidth: "120",
	                style: "aui-center",
	            },
	            {
	                headerText: "당해6월출고수량",
	                dataField: "curr_out_qty06",
	                width: "120",
	                minWidth: "120",
	                style: "aui-center",
	            },
	            {
	                headerText: "당해7월출고수량",
	                dataField: "curr_out_qty07",
	                width: "120",
	                minWidth: "120",
	                style: "aui-center",
	            },
	            {
	                headerText: "당해8월출고수량",
	                dataField: "curr_out_qty08",
	                width: "120",
	                minWidth: "120",
	                style: "aui-center",
	            },
	            {
	                headerText: "당해9월출고수량",
	                dataField: "curr_out_qty09",
	                width: "120",
	                minWidth: "120",
	                style: "aui-center",
	            },
	            {
	                headerText: "당해10월출고수량",
	                dataField: "curr_out_qty10",
	                width: "120",
	                minWidth: "120",
	                style: "aui-center",
	            },
	            {
	                headerText: "당해11월출고수량",
	                dataField: "curr_out_qty11",
	                width: "120",
	                minWidth: "120",
	                style: "aui-center",
	            },
	            {
	                headerText: "당해12월출고수량",
	                dataField: "curr_out_qty12",
	                width: "120",
	                minWidth: "120",
	                style: "aui-center",
	            },
	            ];

			// 실제로 #grid_wrap에 그리드 생성
            auiGridExcel = AUIGrid.create("#auiGridExcel", columnLayout, gridPros);
            // 그리드 갱신
            AUIGrid.setGridData(auiGridExcel, []);
		}

		function goSearch() {
			// 조회 버튼 눌렀을경우 1페이지로 초기화
			page = 1;
			moreFlag = "N";

			fnSearch(function(result){

				AUIGrid.setGridData(auiGrid, result.list);
				AUIGrid.setGridData(excelGrid, result.list);

				$("#total_cnt").html(result.total_cnt);
				$("#curr_cnt").html(result.list.length);
				if (result.more_yn == 'Y') {
					moreFlag = "Y";
					page++;
				};
			});
		}

		// 스크롤 위치가 마지막과 일치한다면 추가 데이터 요청함
		function fnScollChangeHandelr(event) {
			if(event.position == event.maxPosition && moreFlag == "Y" && isLoading == false) {
				goMoreData();
			};
		}

		// 스크롤 페이지
		function goMoreData() {
			fnSearch(function(result){
				result.more_yn == "N" ? moreFlag = "N" : page++;
				if (result.list.length > 0) {

					AUIGrid.appendData("#auiGrid", result.list);
					AUIGrid.appendData(excelGrid, result.list);

					$("#curr_cnt").html(AUIGrid.getGridData(auiGrid).length);
				};
			});
		}

		//조회
		function fnSearch(successFunc) {
			isLoading = true;

			if($M.checkRangeByFieldName("s_start_dt", "s_end_dt", true) == false) {
				return false;
			};

			var s_month =  $M.getValue("s_month");

			if(s_month.toString().length == 1) {
				s_month = '0' + s_month;
			};

			var param = {
					"s_year_mon"			: $M.getValue("s_year") + s_month,
					"s_maker_cd"			: $M.getValue("s_maker_cd"),
					"s_part_production_cd"	: $M.getValue("s_part_production_cd"),
					"s_part_no_st"			: $M.getValue("s_part_no_st"),
					"s_part_no_ed"			: $M.getValue("s_part_no_ed"),
					"s_part_real_check_cd"	: $M.getValue("s_part_real_check_cd"),
					"s_warehouse_cd_str"	: $M.getValue("s_warehouse_cd"),
					"s_unearned"			: $M.getValue("unearned"),
					"s_long_term_stock"		: $M.getValue("longTermStock"),
					"s_non_part"			: $M.getValue("nonPart"),
					"s_stop_sales"			: $M.getValue("stopSales"),
					"page" : page,
					"rows" : $M.getValue("s_rows"),
				};

			$M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method : 'get'},
				function(result){
					isLoading = false;
					if(result.success) {
						successFunc(result);
					};
				}
			);
		}

		// 그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn: true,
				editable : false,
				// fixedColumnCount : 3,
			};

			// AUIGrid 칼럼 설정

			var columnLayout = [
				{
				    headerText: "부품번호",
				    dataField: "part_no",
				    width : "160",
				    minWidth : "160",
					style : "aui-center"
				},
				{
					headerText : "신번호",
					dataField : "part_new_no",
				    width : "120",
				    minWidth : "120",
					style : "aui-center"
				},
				{
				    headerText: "부품명",
				    dataField: "part_name",
				    width : "220",
				    minWidth : "220",
					style : "aui-left"
				},
				{
				    headerText: "메이커",
				    dataField: "maker_name",
				    width : "70",
				    minWidth : "70",
					style : "aui-center"
				},
				{
				    headerText: "매입처",
				    dataField: "cust_name",
				    width : "150",
				    minWidth : "150",
					style : "aui-center"
				},
				{
				    headerText: "기간재고",
				    dataField: "serach_mon_qty",
					dataType : "numeric",
					formatString : "#,##0",
				    width : "70",
				    minWidth : "70",
					style : "aui-center"
				},
				{
				    headerText: "현재고",
				    dataField: "curr_mon_qty",
					dataType : "numeric",
					formatString : "#,##0",
				    width : "70",
				    minWidth : "70",
					style : "aui-center"
				},
				{
				    headerText: "평균매입가",
				    dataField: "part_avg_price",
					dataType : "numeric",
					formatString : "#,##0",
				    width : "95",
				    minWidth : "95",
					style : "aui-right"
				},
				{
				    headerText: "현재고원가",
				    dataField: "serach_mon_amt",
					dataType : "numeric",
					formatString : "#,##0",
				    width : "95",
				    minWidth : "95",
					style : "aui-right"
				},
				{
				    headerText: "총적정재고",
				    dataField: "safe_stock",
					dataType : "numeric",
					formatString : "#,##0",
				    width : "70",
				    minWidth : "70",
					style : "aui-center"
				},
				{
				    headerText: "안전재고",
				    dataField: "part_safe_stock",
					dataType : "numeric",
					formatString : "#,##0",
				    width : "70",
				    minWidth : "70",
					style : "aui-center"
				},
				{
				    headerText: "분류구분",
				    dataField: "part_real_check_cd",
				    width : "70",
				    minWidth : "70",
					style : "aui-center"
				},
				{
				    headerText: "산출구분",
				    dataField: "part_output_price_cd",
				    width : "70",
				    minWidth : "70",
					style : "aui-center"
				},
				{
				    headerText: "그룹코드",
				    dataField: "part_group_cd",
				    width : "70",
				    minWidth : "70",
					style : "aui-center"
				},
				{
				    headerText: "생산구분",
				    dataField: "part_production_cd",
				    width : "70",
				    minWidth : "70",
					style : "aui-center"
				},
				{
				    headerText: "관리구분",
				    dataField: "part_mng_cd",
				    width : "70",
				    minWidth : "70",
					style : "aui-center"
				},
				{
				    headerText: "최종판매일",
				    dataField: "last_sale_dt",
					style : "aui-center",
					dataType : "date",
					formatString : "yy-mm-dd",
					width : "75",
					minWidth : "75",
				},
			];

			// 그리드 출력
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, []);
			// 클릭 시 팝업페이지 호출
 			AUIGrid.bind(auiGrid, "cellClick", function(event) {
 				if(event.dataField == "part_trans_req_no") {
 					var popupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=600, left=0, top=0";
					$M.goNextPage("/part/part0201p01", "", {popupStatus : popupOption});
 				}
			});

			AUIGrid.bind(auiGrid, "vScrollChange", fnScollChangeHandelr);
		}


		// 그리드 다운로드 셀 - 적용 아이템 엑셀 다운로드그리드 생성
		function createExcelGrid() {
			// 그리드 속성 설정
			var gridPros = {};
			var columnLayout = [
				{
				    headerText: "부품번호",
				    dataField: "part_no",
				    width : "10%",
					style : "aui-center"
				},
				{
					headerText : "신번호",
					dataField : "deal_cust_name",
					width : "10%",
					style : "aui-center"
				},
				{
				    headerText: "부품명",
				    dataField: "part_name",
				    width : "10%",
					style : "aui-center"
				},
				{
				    headerText: "메이커",
				    dataField: "maker_name",
					style : "aui-center"
				},
				{
				    headerText: "매입처",
				    dataField: "cust_name",
					style : "aui-center"
				},
				{
				    headerText: "기간재고",
				    dataField: "serach_mon_qty",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-center"
				},
				{
				    headerText: "현재고",
				    dataField: "curr_mon_qty",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-center"
				},
				{
				    headerText: "평균매입가",
				    dataField: "part_avg_price",
					style : "aui-center"
				},
				{
				    headerText: "현재고원가",
				    dataField: "serach_mon_amt",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-center"
				},
				{
				    headerText: "총적정재고#",
					dataType : "numeric",
					formatString : "#,##0",
				    dataField: "safe_stock",
					style : "aui-center"
				},
				{
				    headerText: "안전재고",
				    dataField: "part_safe_stock",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-center"
				},
				{
				    headerText: "분류구분",
				    dataField: "part_real_check_cd",
					style : "aui-center"
				},
				{
				    headerText: "산출구분",
				    dataField: "part_output_price_cd",
					style : "aui-center"
				},
				{
				    headerText: "그룹코드",
				    dataField: "part_group_cd",
					style : "aui-center"
				},
				{
				    headerText: "생산구분",
				    dataField: "part_production_cd",
					style : "aui-center"
				},
				{
				    headerText: "관리구분",
				    dataField: "part_mng_cd",
					style : "aui-center"
				},
				{
				    headerText: "최종판매일",
				    dataField: "last_sale_dt",
					style : "aui-center"
				},
				{
				    headerText: "최초등록일",
				    dataField: "reg_date",
					style : "aui-center"
				},
				{
				    headerText: "최종매입일",
				    dataField: "part_last_in_dt",
					style : "aui-center"
				},
				{
				    headerText: "최종매입가",
				    dataField: "part_last_in_price",
					style : "aui-center",
				},
				{
				    headerText: "List Price",
				    dataField: "list_price",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-center",
				},
				{
				    headerText: "Net Price",
				    dataField: "net_price",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-center",
				},
				{
				    headerText: "Special",
				    dataField: "special_price",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-center",
				},
				{
				    headerText: "입고단가",
				    dataField: "in_stock_price",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-center",
				},
				{
				    headerText: "소비단가",
				    dataField: "cust_price",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-center",
				},
				{
				    headerText: "전략가",
				    dataField: "strategy_price",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-center",
				},
				{
					// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
				    // headerText: "대리점가",
				    headerText: "위탁판매점가",
				    dataField: "mng_agency_price",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-center",
				},
				{
				    headerText: "당해입고수량",
				    dataField: "in_qty",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-center",
				},
				{
				    headerText: "당해출고수량",
				    dataField: "out_qty",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-center",
				},
				{
				    headerText: "당해출고금액",
				    dataField: "out_amt",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-center",
				},
				{
				    headerText: "전년출고수량",
				    dataField: "before_out_qty",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-center",
				},
				{
				    headerText: "전년출고수량",
				    dataField: "before_out_qty2",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-center",
				},
				{
				    headerText: "01월",
				    dataField: "out_qty_mon01",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-center",
				},
				{
				    headerText: "02월",
				    dataField: "out_qty_mon02",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-center",
				},
				{
				    headerText: "03월",
				    dataField: "out_qty_mon03",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-center",
				},
				{
				    headerText: "04월",
				    dataField: "out_qty_mon04",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-center",
				},
				{
				    headerText: "05월",
				    dataField: "out_qty_mon05",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-center",
				},
				{
				    headerText: "06월",
				    dataField: "out_qty_mon06",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-center",
				},
				{
				    headerText: "07월",
				    dataField: "out_qty_mon07",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-center",
				},
				{
				    headerText: "08월",
				    dataField: "out_qty_mon08",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-center",
				},
				{
				    headerText: "09월",
				    dataField: "out_qty_mon09",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-center",
				},
				{
				    headerText: "10월",
				    dataField: "out_qty_mon10",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-center",
				},
				{
				    headerText: "11월",
				    dataField: "out_qty_mon11",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-center",
				},
				{
				    headerText: "12월",
				    dataField: "out_qty_mon12",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-center",
				},
			];
			excelGrid = AUIGrid.create("#excelGrid", columnLayout, gridPros);
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
								<col width="60px">
								<col width="130px">
								<col width="55px">
								<col width="130px">
								<col width="65px">
								<col width="80px">
								<col width="65px">
								<col width="300px">
								<col width="60px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th>조회년월</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-7">
												<select class="form-control width120px" name="s_year" id="s_year">
														<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
															<option value="${i}" <c:if test="${i eq inputParam.s_current_year}">selected="selected"</c:if>>${i}년</option>
														</c:forEach>
												</select>
											</div>
											<div class="col-5">
												<select class="form-control width120px" name="s_month" id="s_month">
														<c:forEach var="i" begin="01" end="12" step="1">
															<option value="${i}" <c:if test="${i eq fn:substring(inputParam.s_current_mon, 4, 6)}">selected="selected"</c:if>>${i}월</option>
														</c:forEach>
												</select>
											</div>
										</div>
									</td>
									<th>메이커</th>
									<td>
										<select class="form-control" id="s_maker_cd" name="s_maker_cd">
											<option value ="">- 전체 -</option>
											<c:forEach items="${makerList}" var="item" varStatus="status">
												<option value="${item.code_value}">${item.code_name}</option>
											</c:forEach>
<%-- 											<c:forEach items="${codeMap['MAKER']}" var="item"> --%>
<%-- 												<c:if test="${item.code_v1 eq 'Y'}"><option value="${item.code_value}">${item.code_name}</option></c:if> --%>
<%-- 											</c:forEach> --%>
										</select>
									</td>
									<th>생산구분</th>
									<td>
										<select id="s_part_production_cd" name="s_part_production_cd" class="form-control">
											<option value="">- 전체 -</option>
											<c:forEach items="${codeMap['PART_PRODUCTION']}" var="item">
												<option value="${item.code_value}">${item.code_name}</option>
											</c:forEach>
										</select>
									</td>
									<th>부품코드</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col" style="width: 140px;">
												<div class="input-group">
													<input type="text" class="form-control border-right-0" id="s_part_no_st" name="s_part_no_st">
													<input type="hidden" class="form-control border-right-0" id="s_part_name_st" name="s_part_name_st">
													<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchPartPanel('setPartInfoSt', 'N');"><i class="material-iconssearch"></i></button>
												</div>
											</div>
											<div class="col text-center" style="width: 10px;">
												~
											</div>
											<div class="col" style="width: 140px;">
												<div class="input-group">
													<input type="text" class="form-control border-right-0" id="s_part_no_ed" name="s_part_no_ed">
													<input type="hidden" class="form-control border-right-0" id="s_part_name_ed" name="s_part_name_ed">
													<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchPartPanel('setPartInfoEd', 'N');"><i class="material-iconssearch"></i></button>
												</div>
											</div>
										</div>
									</td>
									<th>분류구분</th>
									<td colspan="2">
										<div class="input-group">
											<input type="text" style="width : 300px;" class="form-control border-right-0"
											id="s_part_real_check_cd"
											name="s_part_real_check_cd"
											easyui="combogrid"
											header="Y"
											easyuiname="groupCode"
											panelwidth="360"
											maxheight="155"
											textfield="code_name"
											multi="N"
											enter=""
											idfield="code" />
										</div>
									</td>
								</tr>
								<tr>
									<th>부품창고</th>
									<td colspan="5">
										<div class="input-group">
											<input type="text" style="width : 100%;" class="form-control border-right-0"
											id="s_warehouse_cd"
											name="s_warehouse_cd"
											easyui="combogrid"
											header="Y"
											easyuiname="warehouseList"
											panelwidth="360"
											maxheight="155"
											textfield="code_name"
											multi="Y"
											enter=""
											idfield="code_value" />
										</div>
									</td>
									<th>포함여부</th>
									<td>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="checkbox" id="unearned" name="unearned" value="Y">
											<label class="form-check-label">미수입</label>
										</div>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="checkbox" id="longTermStock" name="longTermStock" value="Y">
											<label class="form-check-label">장기재고</label>
										</div>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="checkbox" id="nonPart" name="nonPart" value="Y">
											<label class="form-check-label">비부품</label>
										</div>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="checkbox" id="stopSales" name="stopSales" value="Y">
											<label class="form-check-label">매출정지</label>
										</div>
									</td>
									<td>
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
									</td>
								</tr>
							</tbody>
						</table>
					</div>
<!-- /검색영역 -->
<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<h4>조회결과</h4>
						<div class="btn-group">
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->
					<div style="margin-top: 5px; height: 500px;" id="auiGrid"></div>
                    <div id="auiGridExcel" style="display:none;"></div>
<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">
						<div class="left">
							<jsp:include page="/WEB-INF/jsp/common/pagingFooter.jsp"/>
						</div>
					</div>
					<div id="excelGrid" style="height: 0px; width: 330%; overflow: hidden;"></div>
<!-- /그리드 서머리, 컨트롤 영역 -->
				</div>

			</div>
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
		</div>
<!-- /contents 전체 영역 -->
</div>
</form>
</body>
</html>
