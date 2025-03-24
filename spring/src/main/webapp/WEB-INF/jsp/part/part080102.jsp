<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 생산/선적오더관리 > 어테치먼트 발주관리 > 어테치먼트 발주관리-부품 > null
-- 작성자 : 박예진
-- 최초 작성일 : 2021-08-11 12:00:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var myJQCalendarRenderer = {
				type : "JQCalendarRenderer", // datepicker 달력 렌더러 사용
				defaultFormat : "yyyymmdd", // 원래 데이터 날짜 포맷과 일치 시키세요. (기본값: "yyyy/mm/dd")
				onlyCalendar : false, // 사용자 입력 불가, 즉 달력으로만 날짜입력 ( 기본값: true )
				maxlength : 8,
				onlyNumeric : true, // 숫자만
                editable : true, 
				validator : function(oldValue, newValue, rowItem) { // 에디팅 유효성 검사
					return fnCheckDate(oldValue, newValue, rowItem);
				},
				showEditorBtnOver : true
		};
		var myInputEditRenderer = {
                type : "InputEditRenderer",
                onlyNumeric : true,
        };
		
		$(document).ready(function() {
			// 그리드 생성
			createAUIGrid();
			goSearch();
		});
		
		// 부품판매현황-기간별 목록 조회
		function goSearch() {
			
			var param = {
				"s_start_mon" : $M.getValue("s_start_year") + $M.getValue("s_start_mon").padStart(2, '0'),
				"s_end_mon" : $M.getValue("s_end_year") + $M.getValue("s_end_mon").padStart(2, '0'),
				"s_maker_cd" : $M.getValue("s_maker_cd"),
			};
			
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: "GET"}, 
				function(result) {
					fnResult(result);
			});
		}
		
		// 조회시작월이 조회종료월보다 이후면 조회종료월 동일하게 세팅
		function fnChangeMon() {
			var startMon = $M.getValue("s_start_year") + $M.getValue("s_start_mon").padStart(2, '0');
			var endMon = $M.getValue("s_end_year") + $M.getValue("s_end_mon").padStart(2, '0');
// 			var startDt = $M.dateFormat($M.toDate(startMon), 'yyyyMMdd');
// 			var endDt = $M.dateFormat($M.toDate(endMon), 'yyyyMMdd');
			if(startMon > endMon) {
				$M.setValue("s_end_year", $M.getValue("s_start_year"));
				$M.setValue("s_end_mon", $M.getValue("s_start_mon"));
			}
			
		}
		
		// 데이터 조회 후 그리드 컬럼 세팅
		function fnResult(result) {
			if (result.success) {
				var columnLayout = [
					{
						headerText: "장비발주현황",
						dataField: "mch_ship_dt",
						width: "120",
	                    minWidth: "120",
	                    style: "aui-center",
	                    editable : false, 
	                    colSpan: 2, // 헤더 가로병합
	                    cellColMerge: true, // 셀 가로병합
	                    cellColSpan: 2, // 셀 가로병합
	                    cellMerge: true, // 셀 세로병합
	                    renderer : {
				            type : "TemplateRenderer",
				     	},
				     	labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
							if (item["format_check_yn"] == "Y") {
								value = $M.dateFormat(value, 'yyyy-MM-dd');
							};
							return value;
						},
					},
					{
	                    dataField: "mch_in_plan_dt",
	                    width: "120",
	                    minWidth: "120",
	                    editable : false,
						labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
							if (item["format_check_yn"] == "Y") {
								value = $M.dateFormat(value, 'yyyy-MM-dd');
							};
							return value;
						},
	                },
					{
					    headerText: "장비<br>대수합계",
					    dataField: "mch_total",
	                    editable : false, 
						width : "60",
						minWidth : "60",
						style : "attach-order-col",
						headerStyle : "attach-order-col",
						labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
							value = AUIGrid.formatNumber(value, "#,##0");
							return value == 0 ? "" : value;
						},
					},
					{
						headerText: "모델 별 어테치먼트 발주관리",
						dataField: "part_order_no",
						width: "120",
	                    minWidth: "120",
	                    editable : true, 
	                    colSpan: 2, // 헤더 가로병합
	                    cellColMerge: true, // 셀 가로병합
	                    cellColSpan: 3, // 셀 가로병합
	                    cellMerge: true, // 셀 세로병합
	                    renderer : {
				            type : "TemplateRenderer",
				     	},
				     	styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
				     		if(item["temp_part_order_yn"] == "Y") {
								return "aui-attach-part-order-row-style";
				     		} else if(item["part_order_no"].startsWith("PO")) {
								return "aui-popup";
							} else if((item["part_order_no"] == "" && item["temp_part_order_yn"] != "Y") || rowIndex == 0) {
								return "aui-center";
							}
				     		return "aui-as-cell-row-style";
						},
						labelFunction : function (rowIndex, columnIndex, value, headerText, item) {
							if(value != "" && value != undefined){
								return value;
							}else if (item["temp_part_order_yn"] != "Y"){
								var template = '<div class="aui-grid-renderer-base" style="white-space: nowrap; display: inline-block; width: 100%; max-height: 24px;">';
								template += '<span class="aui-grid-button-renderer aui-grid-button-percent-width" onclick="javascript:goPartOrderPopup(\'' + item["machine_ship_plan_seq"] + '\')">발주</span></div>'
								
								return template;
							}
						}
					},
					{
	                    dataField: "part_order_dt",					// 확정 발주일자
	                    width: "120",
	                    minWidth: "120",
						editRenderer : {
             				type : "ConditionRenderer",
             				conditionFunction : function(rowIndex, columnIndex, value, item, dataField) {
             					if(item["mch_order_mon"] != "" && item["mch_order_mon"] != undefined){
             						return myJQCalendarRenderer;
             					}
             				}
             			},
             			styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
             				return fnChangeStyle(rowIndex, item, "N");
						},
						labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
							if(value != "" && value != undefined) {
								if ((item["mch_order_mon"] != "" && item["mch_order_mon"] != undefined) || item["format_check_yn"] == "Y") {
									value = $M.dateFormat(value, 'yyyy-MM-dd');
								};
							};
							return value;
						}
	                },
					{
					    headerText: "모델명",
					    dataField: "",
						width : "90",
						minWidth : "90",
						children : [
							{
								headerText : "어테치먼트",
								dataField : "",
								width : "90",
								minWidth : "90",
								style : "aui-center",
								children : [
									{
										headerText : "잔여개수",
										dataField : "part_in_plan_dt",			// 부품 입고 예정일자
					                    editable : false, 
										width : "90",
										minWidth : "90",
										labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
											if(value != "" && value != undefined) {
												if ((item["mch_order_mon"] != "" && item["mch_order_mon"] != undefined) || item["format_check_yn"] == "Y") {
													value = $M.dateFormat(value, 'yyyy-MM-dd');
												};
											}
											return value;
										},
										styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
											return fnChangeStyle(rowIndex, item, "N");
										}
									}
								]
							}
						]
					},
	                {
	                	dataField: "machine_bucket_seq",		// 부품가발주 저장을 위해 hidden값
	                	visible : false
	                },
	                {
	                	dataField: "machine_ship_plan_seq",		// 부품발주 연결을 위해 hidden값
	                	visible : false
	                },
	                {
	                	dataField: "mch_order_mon",				// 장비생산발주월
	                	visible : false
	                },
	                {
	                	dataField: "format_check_yn",			// 포맷팅 유무
	                	visible : false
	                },
	                {
	                	dataField: "total_yn",					// 합계 행 유무
	                	visible : false
	                },
	                {
	                	dataField: "temp_part_order_yn",		// 가발주 구분 값
	                	visible : false
	                },
	                {
	                	dataField: "merge_cancel_yn",			// 가로병합 삭제여부
	                	visible : false
	                },
				];
		
				var hList = result.bucketNameList;
				
				for(var i=0; i < hList.length; i++) {
					var headerTextName = hList[i].bucket_name;
					var dataFieldName = "a_" + hList[i].machine_bucket_seq + "";
					var machine_bucket_seq = hList[i].machine_bucket_seq;
					var qty = 0;

					if(hList[i].part_no != "") {
						qty = hList[i].current_stock;
					}
	
					var bucketNameObj = {
						headerText: headerTextName,
						dataField: dataFieldName,
						width: "85",
						minWidth: "85",
						style: "aui-center",
						children : [
							{
								headerText : "대버켓",
								dataField : "bucket_B",
								width : "50",
								minWidth : "50",
								style : "aui-center",
								children : [
									{
										headerText : "<div onclick='javascript:goPart("+'"' + hList[i]["a_" + machine_bucket_seq + "_b_part"] + '"'+");'><U>" + hList[i]["a_" + machine_bucket_seq + "_b"] + "</U></div>", 
										dataField : "a_" + machine_bucket_seq + "_b",
										width : "50",
										minWidth : "50",
										headerStyle : "attach-order-header",
										style : "aui-center",
										editRenderer : {
										    type : "InputEditRenderer",
										    onlyNumeric : true,
										    autoThousandSeparator : true, // 천단위 구분자 삽입 여부 (onlyNumeric=true 인 경우 유효)
										    allowPoint : false // 소수점(.) 입력 가능 설정
										},
										styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
											return fnChangeStyle(rowIndex, item, "Y");
										},
										labelFunction : function(rowIndex, columnIndex, value, headerText, map) {
											value = AUIGrid.formatNumber(value, "#,##0");
											return value == 0 ? "" : value;
										},
									}
								]
							}, 
							{
								headerText : "중버켓",
								dataField : "bucket_M",
								width : "50",
								minWidth : "50",
								style : "aui-center",
								children : [
									{
										headerText : "<div onclick='javascript:goPart("+'"' + hList[i]["a_" + machine_bucket_seq + "_m_part"] + '"'+");'><U>" + hList[i]["a_" + machine_bucket_seq + "_m"] + "</U></div>",
										dataField : "a_" + machine_bucket_seq + "_m",
										width : "50",
										minWidth : "50",
										headerStyle : "attach-order-header",
										style : "aui-center",
										editRenderer : {
										    type : "InputEditRenderer",
										    onlyNumeric : true,
										    autoThousandSeparator : true, // 천단위 구분자 삽입 여부 (onlyNumeric=true 인 경우 유효)
										    allowPoint : false // 소수점(.) 입력 가능 설정
										},
										styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
											return fnChangeStyle(rowIndex, item, "Y");
										},
										labelFunction : function(rowIndex, columnIndex, value, headerText, map) {
											value = AUIGrid.formatNumber(value, "#,##0");
											return value == 0 ? "" : value;
										},
									}
								]
							}, 
							{
								headerText : "소버켓",
								dataField : "bucket_S",
								width : "50",
								minWidth : "50",
								style : "aui-center",
								children : [
									{
										headerText : "<div onclick='javascript:goPart("+'"' + hList[i]["a_" + machine_bucket_seq + "_s_part"] + '"'+");'><U>" + hList[i]["a_" + machine_bucket_seq + "_s"] + "</U></div>",
										dataField : "a_" + machine_bucket_seq + "_s",
										width : "50",
										minWidth : "50",
										headerStyle : "attach-order-header",
										style : "aui-center",
										editRenderer : {
										    type : "InputEditRenderer",
										    onlyNumeric : true,
										    autoThousandSeparator : true, // 천단위 구분자 삽입 여부 (onlyNumeric=true 인 경우 유효)
										    allowPoint : false // 소수점(.) 입력 가능 설정
										},
										styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
											return fnChangeStyle(rowIndex, item, "Y");
										},
										labelFunction : function(rowIndex, columnIndex, value, headerText, map) {
											value = AUIGrid.formatNumber(value, "#,##0");
											return value == 0 ? "" : value;
										},
									}
								]
							}, 
							{
								headerText : "퀵클램프",
								dataField : "bucket_Q",
								width : "60",
								minWidth : "60",
								style : "aui-center",
								children : [
									{
										// headerText : hList[i]["a_" + machine_bucket_seq + "_q"], // 퀵클램프 센터제고 조회 가능하도록 수정
										headerText : "<div onclick='javascript:goPart("+'"' + hList[i]["a_" + machine_bucket_seq + "_q_part"] + '"'+");'><U>" + hList[i]["a_" + machine_bucket_seq + "_q"] + "</U></div>",
										dataField : "a_" + machine_bucket_seq + "_q",
										width : "60",
										minWidth : "60",
										headerStyle : "attach-order-header",
										style : "aui-center",
										editRenderer : {
										    type : "InputEditRenderer",
										    onlyNumeric : true,
										    autoThousandSeparator : true, // 천단위 구분자 삽입 여부 (onlyNumeric=true 인 경우 유효)
										    allowPoint : false // 소수점(.) 입력 가능 설정
										},
										styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
											return fnChangeStyle(rowIndex, item, "Y");
										},
										labelFunction : function(rowIndex, columnIndex, value, headerText, map) {
											value = AUIGrid.formatNumber(value, "#,##0");
											return value == 0 ? "" : value;
										},
									}
								]
							}, 
						],
						headerTooltip : { // 헤더 툴팁 표시 HTML 양식
						    show : true,
						    tooltipHtml : '<div>호환장비 : '+hList[i].model_name+'</div>'
						}
					}
					
					columnLayout.push(bucketNameObj);
					
					AUIGrid.changeColumnLayout(auiGrid, initColumnLayout(columnLayout));
 					AUIGrid.setGridData(auiGrid, result.list);
 					

 					$("#auiGrid").resize();
				}

			    AUIGrid.setFixedColumnCount(auiGrid, 6); // (Q&A 12742) 이진동님 요청으로 틀고정 추가 21.09.29 박예진
			}
		}
		
		// 그리드 cell별 스타일 세팅
		function fnChangeStyle(rowIndex, item, bucketYn) {
			if(item["temp_part_order_yn"] == "Y") {
				return "aui-attach-part-order-row-style";
			} else if(item["part_order_no"].startsWith("PO") || item["part_order_no"] == "" || rowIndex == 0) {
				return "aui-center";
			} else if ((item["mch_order_mon"] != "" && item["mch_order_mon"] != undefined)) {
				return "aui-attach-part-order-row-style";
			} else if (bucketYn == "Y" && item["total_yn"] != "Y") {
				return "aui-center";
			}
			return "aui-as-cell-row-style";
		}
		
		// 저장
		function goSave() {
			if (fnChangeGridDataCnt(auiGrid) == 0){
				alert(msg.alert.data.noChanged);
				return false;
			};
			var frm = fnGridObjDataToForm(auiGrid);

			$M.goNextPageAjaxSave(this_page + "/save", frm, {method : 'POST'}, 
				function(result) {
					if(result.success) {
						goSearch();
					};
				}
			);
		}
		
		//엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "어테치먼트 발주관리-부품", "");
		}
		
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				height: 515,
				showHeader : true,
				enableSorting : false,
				showRowNumColumn: true,
                enableCellMerge: true, // 셀병합 사용여부
                cellMergeRowSpan: true,
                editable : true,
                rowIdField : "_$uid",
				headerHeight : 35,
	            editableOnFixedCell : true, // (Q&A 12742) 이진동님 요청으로 틀고정 추가 21.09.29 박예진
// 				fixedColumnCount : 6,
				cellColMergeFunction : function(rowIndex, columnIndex, item) {
					if(item["merge_cancel_yn"] == "Y") {
						return false; // false 를 반환하면 해당 행은 가로 병합 하지 않습니다.
					}
					return true; // true 는 가로 병합 실행
				}
			};

			// 컬럼레이아웃
			var columnLayout = [];

			auiGrid = AUIGrid.create("#auiGrid", initColumnLayout(columnLayout), gridPros);
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.bind(auiGrid, "cellEditBegin", function(event) {
				if(event.item["mch_order_mon"] == "" || event.item["mch_order_mon"] == undefined){
					return false;
				} else {
					return true;
				}
			});
			AUIGrid.bind(auiGrid, "cellEditEnd", function(event) {
				if (event.value == "") {
					return null;
				}
			});
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if (event.dataField == "part_order_no" && event.item["part_order_no"].startsWith("PO")) {
					var param = {
							part_order_no : event.item["part_order_no"]
					};
					var poppupOption = "";
					$M.goNextPage('/part/part0403p01', $M.toGetParam(param), {popupStatus : poppupOption});
				}
			});

			$("#auiGrid").resize();
		}
		
		// 부품 발주 연동
		function goPartOrderPopup(mchShipPlanSeq) {
			var param = {
					"s_maker_cd" : $M.getValue("s_maker_cd"),
					"machine_ship_plan_seq" : mchShipPlanSeq
			};
			var poppupOption = "";
			$M.goNextPage('/part/part040301', $M.toGetParam(param), {popupStatus : poppupOption});
		}
		
		function goPart(partNo){
			console.log("파츠 ", partNo)
			if(partNo == ''){
				alert("해당하는 부품이 없습니다.");
				return;
			}
			var popupOption = "";
			var param = {
				"part_no" : partNo
			};
			$M.goNextPage('/part/part0101p01', $M.toGetParam(param), {popupStatus : popupOption});
		}


		// 호환모델설정 - 2022.12.14 류성진
		function goSetting(){
			var popupOption = "";
			var param = {
				// "part_no" : partNo
			};
			$M.goNextPage('/part/part080102p01', $M.toGetParam(param), {popupStatus : popupOption});
		}
		
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<div class="layout-box">
<!-- contents 전체 영역 -->
		<div class="content-wrap">
<!-- 검색영역 -->		
					<div class="search-wrap mt10">
						<table class="table table-fixed">
							<colgroup>
								<col width="60px">
								<col width="140px">		
								<col width="20px">
								<col width="140px">				
								<col width="60px">
								<col width="90px">				
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th>조회년월</th>
									<td>		
										<div class="form-row inline-pd" onchange="javascript:fnChangeMon();">							
											<div class="col-7">
												<jsp:include page="/WEB-INF/jsp/common/yearSelect.jsp">
													<jsp:param name="year_name" value="s_start_year"/>
													<jsp:param name="sort_type" value="d"/>
													<jsp:param name="select_year" value="${inputParam.s_start_year}"/>
												</jsp:include>
											</div>
											<div class="col-5">
												<select class="form-control" id="s_start_mon" name="s_start_mon" onchange="javascript:fnChangeMon();">
													<c:forEach var="i" begin="01" end="12" step="1">
														<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i == inputParam.s_start_mon}">selected</c:if>>${i}월</option>
													</c:forEach>
												</select>
											</div>
										</div>
									</td>
									<td class="text-center">~</td>
									<td>
										<div class="form-row inline-pd">							
											<div class="col-7">
												<jsp:include page="/WEB-INF/jsp/common/yearSelect.jsp">
													<jsp:param name="year_name" value="s_end_year"/>
													<jsp:param name="sort_type" value="d"/>
													<jsp:param name="select_year" value="${inputParam.s_end_year}"/>
													<jsp:param name="max_year" value="${inputParam.s_end_year}"/>
												</jsp:include>
											</div>
											<div class="col-5">
												<select class="form-control" id="s_end_mon" name="s_end_mon">
													<c:forEach var="i" begin="01" end="12" step="1">
														<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i == inputParam.s_end_mon}">selected</c:if>>${i}월</option>
													</c:forEach>
												</select>
											</div>
										</div>
									</td>
									<th>메이커</th>
									<td>
										<select id="s_maker_cd" name="s_maker_cd" class="form-control">
<!-- 											<option value="">- 전체 -</option> -->
											<c:forEach items="${codeMap['MAKER']}" var="item">
												<c:if test="${item.code_v2 == 'Y'}">
													<option value="${item.code_value}">${item.code_name}</option>
												</c:if>
											</c:forEach>
										</select>
									</td>
									<td>
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();" >조회</button>
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
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
							</div>
						</div>
					</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->
					<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
					<div class="btn-group mt5">
						<div class="left">
<!-- 							총 <strong class="text-primary" id="total_cnt">0</strong>건 -->
						</div>						
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>
					</div>
				</div>						
			</div>		
<!-- /contents 전체 영역 -->	
</form>
</body>
</html>