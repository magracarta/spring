<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 판매관리 > 장비판매현황-연간 > 연간집계 > null
-- 작성자 : 손광진
-- 최초 작성일 : 2020-09-21 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGrid;

		var dateList;		   // 년월 목록
		var dataFieldName = []; // 펼침 항목(create할때 넣음)

		var stYearMon = "";
		var edYearMon = "";


		$(document).ready(function() {
			fnInit();
			createAUIGrid();
			goSearch();
		});

		//엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, '장비판매현황_연간집계');
		}

		function fnInit() {
			// 그리드 년월목록 호출
			dateList = ${dateList};
		}

		function goSearch() {

			var s_month =  $M.getValue("s_month");
			var s_from_month = $M.getValue("s_from_month");

			if(s_month.toString().length == 1) {
				s_month = '0' + s_month;
			};
			if(s_from_month.toString().length == 1) {
				s_from_month = '0' + s_from_month;
			};

			var param = {
				s_year_mon : $M.getValue("s_year") + s_month,
				s_from_year_mon : $M.getValue("s_from_year") + s_from_month,
				s_rental_yn : $M.getValue("s_rental_yn"),
			};
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						$("#total_cnt").html(result.total_cnt);
						dateList = result.dateList;

						dataFieldName = [];
						destroyGrid();
						createAUIGrid();
						AUIGrid.setGridData(auiGrid, result.list);

						stYearMon = param.s_from_year_mon;
						edYearMon = param.s_year_mon;
					};
				}
			);
		}

		// 그리드 초기화
		function destroyGrid() {
			AUIGrid.destroy("#auiGrid");
			auiGrid = null;
		};


		//그리드생성
		function createAUIGrid() {

			var dataFieldArr = ["total", "total_yk_cnt", "total_etc_cnt", "total_all_cnt"];
			var ykArray  = [];
			var etcArray = [];
			var totArray = [];

			for(var i = 0; i < dateList.length; ++i) {
				dataFieldArr.push(dateList[i].year_mon_field + "_yk_cnt");
				dataFieldArr.push(dateList[i].year_mon_field + "_etc_cnt");
				dataFieldArr.push(dateList[i].year_mon_field + "_tot_cnt");

				ykArray.push(dateList[i].year_mon_field + "_yk_cnt");
				etcArray.push(dateList[i].year_mon_field + "_etc_cnt");
				totArray.push(dateList[i].year_mon_field + "_tot_cnt");
			}
			var gridPros = {
				rowIdField : "_$uid",
				// fixedColumnCount : 6,
				footerPosition : "top",
				height : 555,
				headerHeight : 40,
// 				showFooter : true,
				showFooter : false,
				showRowNumColumn : false,
// 				groupingFields : ["maker_group"],
//               	groupingSummary : {
//               		dataFields : dataFieldArr,
//               	},
	            // 그룹핑 후 셀 병합 실행
	            enableCellMerge : true,
	            // 브랜치에 해당되는 행을 출력 여부
	            showBranchOnGrouping : false,
				useGroupingPanel : false,
				// [15324] 틀 고정
				fixedColumnCount : 3,

				// [23426] 총계 틀 고정
				fixedRowCount : 1,

	         	// 그리드 ROW 스타일 함수 정의
// 	            rowStyleFunction : function(rowIndex, item) {
// 	                if(item._$isGroupSumField) { // 그룹핑으로 만들어진 합계 필드인지 여부
// 	                   return "aui-grid-row-depth3-style";
// 	                }
// 	                return null;
// 				}

				rowStyleFunction : function(rowIndex, item) {
					if(item.maker_name.indexOf("합계") != -1 ||
							item.maker_name.indexOf("총계") != -1 ||
							item.machine_name.indexOf("합계") != -1) {
						return "aui-grid-row-depth3-style";
					}
					return null;
				}
			};
			var columnLayout = [
				{
				    headerText: "분류",
					children : [
						{
							headerText : "메이커",
							dataField : "maker_name",
							width : "100",
							minWidth : "85",
							style : "aui-center",
							cellMerge : true,
// 							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
// 								if(item._$isGroupSumField) { // 그룹핑으로 만들어진 합계 필드인지 여부

// 							    	var oldFieldName = item._$sumFieldValue;
// 							    	var lastChar =  oldFieldName.charAt(oldFieldName.length-1)
// 							    	var newFieldName = "";

// 							    	if(lastChar == "S") {
// 							    		newFieldName = oldFieldName.slice(0,-1) + "소형 합계";
// 							    	} else if(lastChar == "L") {
// 							    		newFieldName = oldFieldName.slice(0,-1) + "대형 합계";
// 							    	} else if(lastChar == "N") {
// 							    		newFieldName = oldFieldName.slice(0,-1) + " 합계";
// 							    	};

// 							    	return newFieldName;
// 							   	}
// 								var maker_name = value.replace(/(L|N|S)/g, "");
// 								return maker_name;
// 							},
						},
						{
							headerText : "규격 코드",
							dataField : "maker_weight_type_cd",
							width : "5%",
							style : "aui-center",
							visible : false,
						},
					]
				},
				{
					headerText : "모델명",
					dataField : "machine_name",
					width : "110",
					minWidth : "85",
					style : "aui-left",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if(item.machine_name.indexOf("합계") != -1 ) {
							return "aui-center";
						}
						return "aui-left";
					},
				},
				{
					headerText : "본사",
					dataField : "total_yk_cnt",
					width : "45",
					minWidth : "25",
					style : "aui-right",
					expFunction : function(rowIndex, columnIndex, item, dataField) {
						var sum = 0;
						for (var i = 0; i < ykArray.length; ++i) {
							sum+=$M.toNum(item[ykArray[i]]);
						}
						return sum == 0 ? "" : sum;
					},
					labelFunction : function(rowIndex, columnIndex, value, headerText) {
						return value == 0 ? "" : value;
					},
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if(value > 0) {
							return "aui-popup";
						}
					},
				},
				{
					// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
					// headerText : "대리점",
					headerText : "위탁판매점",
					dataField : "total_etc_cnt",
					formatString : "#,##0",
					width : "100",
					minWidth : "25",
					style : "aui-right",
					expFunction : function(rowIndex, columnIndex, item, dataField) {
						var sum = 0;
						for (var i = 0; i < etcArray.length; ++i) {
							sum+=$M.toNum(item[etcArray[i]]);
						}
						return sum == 0 ? "" : sum;
					},
					labelFunction : function(rowIndex, columnIndex, value, headerText) {
						return value == 0 ? "" : value;
					},
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if(value > 0) {
							return "aui-popup";
						}
					},
				},
				{
					headerText : "계",
					dataField : "total_all_cnt",
					width : "45",
					minWidth : "25",
					style : "aui-right",
					expFunction : function(rowIndex, columnIndex, item, dataField) {
						var sum = 0;
						for (var i = 0; i < totArray.length; ++i) {
							sum+=$M.toNum(item[totArray[i]]);
						}
						return sum == 0 ? "" : sum;
					},
					labelFunction : function(rowIndex, columnIndex, value, headerText) {
						return value == 0 ? "" : value;
					},
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if(value > 0) {
							return "aui-popup";
						}
					},
				},
				{
// 					headerText : dateList[0].year_mon_text,
					headerText : dateList[0].year_mon_text.substr(0,4) + "<br> /" + dateList[0].year_mon_text.substr(5,2),
					children: [
						{
							headerText : "본사",
							dataField : dateList[0].year_mon_field + "_yk_cnt",
							formatString : "#,##0",
							width : "45",
							minWidth : "25",
							headerStyle : "aui-fold",
							style : "aui-right",
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								return value == 0 ? "" : value;
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value == 0) {
									return "";
								}
								return "aui-popup"
							},
						},
						{
							// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
							// headerText : "대리점",
							headerText : "위탁판매점",
							dataField : dateList[0].year_mon_field + "_etc_cnt",
							formatString : "#,##0",
							headerStyle : "aui-fold",
							width : "100",
							minWidth : "25",
							style : "aui-right",
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								return value == 0 ? "" : value;
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value == 0) {
									return "";
								}
								return "aui-popup"
							},
						},
						{
							headerText : "소계",
							dataField : dateList[0].year_mon_field + "_tot_cnt",
							formatString : "#,##0",
							width : "45",
							minWidth : "25",
							style : "aui-right",
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								return value == 0 ? "" : value;
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value == 0) {
									return "";
								}
								return "aui-popup"
							},
						},
					]
				},

			];
			// 푸터레이아웃
			var footerColumnLayout = [
				{
					labelText : "전체합계",
					positionField : "machine_name",
				},
				{
					dataField : "total_yk_cnt",
					positionField : "total_yk_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "total_etc_cnt",
					positionField : "total_etc_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "total_all_cnt",
					positionField : "total_all_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
			];

			for(var i = 1; i < dateList.length; ++i) {
				var obj = {
// 					headerText : dateList[i].year_mon_text,
					headerText : dateList[i].year_mon_text.substr(0,4) + "<br> /" + dateList[i].year_mon_text.substr(5,2),
					children: [
						{
							headerText : "본사",
							dataField : dateList[i].year_mon_field + "_yk_cnt",
							formatString : "#,##0",
							headerStyle : "aui-fold",
							width : "45",
							minWidth : "25",
							style : "aui-right",
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								return value == 0 ? "" : value;
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value == 0) {
									return "";
								}
								return "aui-popup"
							},
						},
						{
							// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
							// headerText : "대리점",
							headerText : "위탁판매점",
							dataField : dateList[i].year_mon_field + "_etc_cnt",
							formatString : "#,##0",
							headerStyle : "aui-fold",
							width : "100",
							minWidth : "25",
							style : "aui-right",
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								return value == 0 ? "" : value;
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value == 0) {
									return "";
								}
								return "aui-popup"
							},
						},
						{
							headerText : "소계",
							dataField : dateList[i].year_mon_field + "_tot_cnt",
							formatString : "#,##0",
							width : "45",
							minWidth : "25",
							style : "aui-right",
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								return value == 0 ? "" : value;
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value == 0) {
									return "";
								}
								return "aui-popup"
							},
						},
					]
				}

				columnLayout.push(obj);
			}


			for(var i = 0; i < dateList.length; ++i) {
				var sumYkObj =
					{
						dataField : dateList[i].year_mon_field + "_yk_cnt",
						positionField : dateList[i].year_mon_field + "_yk_cnt",
						formatString : "#,##0",
						operation : "SUM",
						style : "aui-right aui-footer",
					};

				var sumEtcObj =
					{
						dataField : dateList[i].year_mon_field + "_etc_cnt",
						positionField : dateList[i].year_mon_field + "_etc_cnt",
						formatString : "#,##0",
						operation : "SUM",
						style : "aui-right aui-footer",
					};

				var sumAllObj =
					{
						dataField : dateList[i].year_mon_field + "_tot_cnt",
						positionField : dateList[i].year_mon_field + "_tot_cnt",
						formatString : "#,##0",
						operation : "SUM",
						style : "aui-right aui-footer",
					};

				footerColumnLayout.push(sumYkObj);
				footerColumnLayout.push(sumEtcObj);
				footerColumnLayout.push(sumAllObj);

			}

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.setFooter(auiGrid, footerColumnLayout);
			$("#auiGrid").resize();

			// 클릭시 팝업 그리드 호출(상세보기)
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField != 'maker_name' && event.dataField != 'machine_name') {
					var eventValue = $M.nvl(event.value, 0);

					if(eventValue == 0) {
						return;
					};

					var orgGubun = ""; // 본사/지사 구분(01:본사, 02:지사)
					if(event.dataField.indexOf("yk") != -1) {
						orgGubun = '01';
					} else if(event.dataField.indexOf("etc") != -1) {
						orgGubun = '02';
					};

					var param = {
						"year_mon" 			: event.dataField.substring(2,8),
						"machine_name" 		: event.item.machine_name,
						"maker_cd" 			: event.item.maker_cd,
						"maker_weight_type" : event.item.maker_weight_type,
						"rental_yn"			: $M.getValue("s_rental_yn"),
						"org_gubun"			: orgGubun,
					}
					if (event.item.machine_name.indexOf("합계") != -1 || event.item.maker_name.indexOf("총계")!= -1 || event.item.maker_name.indexOf("합계") != -1) {
						param.machine_name = "";
					}
					if(event.dataField == 'total_yk_cnt' || event.dataField == 'total_etc_cnt' || event.dataField == 'total_all_cnt') {
						param.year_mon = "";
						param.st_year_mon = stYearMon;
						param.ed_year_mon = edYearMon;
					}

					var popupOption = "";
					$M.goNextPage('/sale/sale0401p01', $M.toGetParam(param), {popupStatus : popupOption});
				}
			});

			// 펼치기 전에 접힐 컬럼 목록
			var auiColList = AUIGrid.getColumnInfoList(auiGrid);
			for (var i = 0; i <auiColList.length; ++i) {
				if (auiColList[i].headerStyle != null && auiColList[i].headerStyle == "aui-fold") {
					dataFieldName.push(auiColList[i].dataField);
				}
			}

			if($("input:checkbox[id='s_toggle_column']").is(":checked") == false){
				for (var i = 0; i < dataFieldName.length; ++i) {
					var dataField = dataFieldName[i];
					AUIGrid.hideColumnByDataField(auiGrid, dataField);
				}
			}
		}

		// 펼침
		function fnChangeColumn(event) {
			var data = AUIGrid.getGridData(auiGrid);
			var target = event.target || event.srcElement;
			if(!target)	return;

			var dataField = target.value;
			var checked = target.checked;

			for (var i = 0; i < dataFieldName.length; ++i) {
				var dataField = dataFieldName[i];

				if(checked) {
					AUIGrid.showColumnByDataField(auiGrid, dataField);
				} else {
					AUIGrid.hideColumnByDataField(auiGrid, dataField);
				}
			}

 		    // 구해진 칼럼 사이즈를 적용 시킴.
// 			var colSizeList = AUIGrid.getFitColumnSizeList(auiGrid, true);
// 		    AUIGrid.setColumnSizeList(auiGrid, colSizeList);
		}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<div class="layout-box">
<!-- contents 전체 영역 -->
		<div class="content-wrap">
<!-- 			<div class="content-box"> -->
<!-- 메인 타이틀 -->
<!-- 				<div class="main-title"> -->
<!-- 					<h2>장비판매현황-전체</h2> -->
<!-- 				</div> -->
<!-- /메인 타이틀 -->
				<div class="search-wrap mt10">
						<table class="table">
							<colgroup>
								<col width="60px">
								<col width="280px">
								<col width="95px">
								<col width="*">
							</colgroup>
							<tbody>
								<tr>
									<th>조회년월</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-auto">
												<select class="form-control width120px" name="s_from_year" id="s_from_year">
														<c:forEach var="i" begin="2007" end="${inputParam.s_current_year}" step="1">
															<option value="${i}" <c:if test="${i eq fn:substring(inputParam.s_from_year_mon, 0, 4)}">selected="selected"</c:if>>${i}년</option>
														</c:forEach>
												</select>
											</div>
											<div class="col-auto">
												<select class="form-control width120px" name="s_from_month" id="s_from_month">
														<c:forEach var="i" begin="01" end="12" step="1">
															<option value="${i}" <c:if test="${i eq fn:substring(inputParam.s_from_year_mon, 4, 6)}">selected="selected"</c:if>>${i}월</option>
														</c:forEach>
												</select>
											</div>
											<div class="col-auto">~</div>
											<div class="col-auto">
												<select class="form-control width120px" name="s_year" id="s_year">
														<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
															<option value="${i}" <c:if test="${i eq inputParam.s_current_year}">selected="selected"</c:if>>${i}년</option>
														</c:forEach>
												</select>
											</div>
											<div class="col-auto">
												<select class="form-control width120px" name="s_month" id="s_month">
														<c:forEach var="i" begin="1" end="12" step="1">
															<option value="${i}" <c:if test="${i eq fn:substring(inputParam.s_current_mon, 4, 6)}">selected="selected"</c:if>>${i}월</option>
														</c:forEach>
												</select>
											</div>
										</div>
									</td>
									<td class="pl15">
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="checkbox" name="s_rental_yn" id="s_rental_yn" value="Y" checked="checked" onchange="goSearch();">
											<label class="form-check-label">렌탈포함</label>
										</div>
									</td>
									<td class="">
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
									</td>
								</tr>
							</tbody>
						</table>
					</div>
<!-- /기본 -->
<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<h4>조회결과</h4>
						<div class="btn-group">
							<div class="right">
								<label for="s_toggle_column" style="color:black;">
									<input type="checkbox" id="s_toggle_column" onclick="javascript:fnChangeColumn(event)">펼침
								</label>
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->

					<div style="margin-top: 5px; height: 550px; width: 100%;" id="auiGrid"></div>

<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">0</strong>건
						</div>
					</div>
		</div>
<!-- /contents 전체 영역 -->
</div>
</form>
</body>
</html>
