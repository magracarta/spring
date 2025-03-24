<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > MS관리 > MS관리-센터별 > null > null
-- 작성자 : 성현우
-- 최초 작성일 : 2020-08-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGrid;
		var areaList;
		var dataFieldName = []; // 펼침 항목(create할때 넣음)
		
		$(document).ready(function() {
			fnInit();
			createAUIGrid();
			goSearch();
		});
		
		function goAmtGraphPopup() {
			goGraphPopup('amt');
		}
		
		function goRatioGraphPopup() {
			goGraphPopup('ratio');
		}
		
		// 수량그래프, 비율그래프 팝업
		function goGraphPopup(type) {
			
			if($M.getValue("s_maker_cd") == "") {
				alert("메이커는 최소 1개 이상 선택해야 합니다.");
				return;
			}

			var sMakerCd = $M.getValue("s_maker_cd").split("#");
			var makerCdArr = [];
			for(var i=0; i<sMakerCd.length; i++) {
				if(makerCdArr.indexOf(sMakerCd[i]) === -1) {
					makerCdArr.push(sMakerCd[i]);
				}
			}

			if(makerCdArr.length > 9) {
				alert("메이커는 최대 9개까지 선택 가능합니다.\n현재 " + makerCdArr.length + "개 선택하셨습니다.");
				return;
			}

			var startDt = fnSetDate($M.getValue("s_start_year"), $M.getValue("s_start_mon"));
			var endDt = fnSetDate($M.getValue("s_end_year"), $M.getValue("s_end_mon"));

			var params = {
				"type" : type,
				"s_start_dt" : startDt,
				"s_end_dt" : endDt,
				"s_center_org_code" : $M.getValue("s_center_org_code"),
				"s_sale_mem_no" : $M.getValue("s_sale_mem_no"),
				"s_ms_machine_type_cd" : $M.getValue("s_ms_machine_type_cd"),
				"s_maker_cd_str" : $M.getArrStr(makerCdArr)
			};
			
			var popupOption = 'scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1000, height=531, left=0, top=0';
			$M.goNextPage('/sale/sale0503p01', $M.toGetParam(params), {popupStatus : popupOption});
		}

		function fnInit() {
			areaList = ${areaList};

			var msMakerCd = "${defaultMakerCd}";
			var msMakerCdArr = msMakerCd.split("#");

			$('#s_maker_cd').combogrid("setValues", msMakerCdArr);
		}

		// 조회
		function goSearch() {
			// validation check
			/* if($M.getValue("s_center_org_code") == "" && $M.getValue("s_sale_mem_no") == "") {
				alert("센터 또는 담당자를 선택해주세요.");
				return;
			} */

			if($M.getValue("s_maker_cd") == "") {
				alert("메이커는 최소 1개 이상 선택해야 합니다.");
				return;
			}

			var sMakerCd = $M.getValue("s_maker_cd").split("#");
			var makerCdArr = [];
			for(var i=0; i<sMakerCd.length; i++) {
				if(makerCdArr.indexOf(sMakerCd[i]) === -1) {
					makerCdArr.push(sMakerCd[i]);
				}
			}

			if(makerCdArr.length > 9) {
				alert("메이커는 최대 9개까지 선택 가능합니다.\n현재 " + makerCdArr.length + "개 선택하셨습니다.");
				return;
			}

			var startDt = fnSetDate($M.getValue("s_start_year"), $M.getValue("s_start_mon"));
			var endDt = fnSetDate($M.getValue("s_end_year"), $M.getValue("s_end_mon"));

			var params = {
				"s_start_dt" : startDt,
				"s_end_dt" : endDt,
				"s_center_org_code" : $M.getValue("s_center_org_code"),
				"s_sale_mem_no" : $M.getValue("s_sale_mem_no"),
				"s_ms_machine_type_cd" : $M.getValue("s_ms_machine_type_cd"),
				"s_maker_cd_str" : $M.getArrStr(makerCdArr)
			};

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(params), {method: "GET"},
					function (result) {
						if (result.success) {
							destroyGrid();
							areaList = result.areaList;
							createAUIGrid();
							AUIGrid.setGridData(auiGrid, result.list);
						}
					}
			);
		}

		// 그리드 초기화
		function destroyGrid() {
			AUIGrid.destroy("#auiGrid");
			auiGrid = null;
			// 조회 후 "펼침" 버튼 초기화
			$("input:checkbox[id='s_toggle_column']").attr("checked", false);
		};

		function fnSetDate(year, mon) {
			if(mon.length == 1) {
				mon = "0" + mon;
			}
			var sYearMon = year + mon;

			return $M.dateFormat($M.toDate(sYearMon), 'yyyyMM');
		}

		// 엑셀 다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "MS관리-센터별");
		}

		function createAUIGrid() {
			// 조회결과
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn: false,
				displayTreeOpen : true,
				useGroupingPanel : false,
				showBranchOnGrouping : false,
				// fixedColumnCount : 6, // 고정칼럼 카운트 지정
				footerPosition: "top",
				showFooter: false,
				enableCellMerge : true,
				cellMergeRowSpan:  true,
				rowSelectionWithMerge : true,
				enableSummaryMerge : true,
				summaryMergePolicy : "all",
				// 그리드 ROW 스타일 함수 정의
				rowStyleFunction : function(rowIndex, item) {
					if((item.ms_machine_sub_type_name.indexOf("소계") != -1 && item.ms_machine_sub_type_name.indexOf("[") == -1)
							|| (item.ms_machine_sub_type_name.indexOf("총계") != -1 && item.ms_machine_sub_type_name.indexOf("[") == -1)) {
						return "aui-grid-row-depth3-style";
					} else if(item.ms_machine_sub_type_name.indexOf("[") != -1) {
						return "aui-ms-col-style";
					}

					return null;
				},
				// [15324] 틀 고정
				fixedColumnCount : 2,
				// [23426] 총계 틀 고정
				fixedRowCount : 1,
			};

			var columnLayout = [
				{
					headerText : "규격",
					dataField : "ms_machine_sub_type_name",
					width : "130",
					minWidth : "20",
					cellMerge : true, // 셀 세로 병합 실행
// 					cellColMerge : true, // 셀 가로 병합 실행
// 					cellColSpan : 2, // 셀 가로 병합 대상은 2개로 설정
					style : "aui-center",
				},
				{
					headerText : "메이커", 
					dataField : "maker_name",
					width : "100",
					minWidth : "20",
					style : "aui-center", 
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						return item.maker_cd == "---" ? "기타" : value;
					}
				},
				{
					headerText : "규격코드",
					dataField : "ms_machine_sub_type_cd",
					visible : false
				},
				{
					headerText : "메이커코드",
					dataField : "maker_cd",
					visible : false
				},
				{
					headerText : "Total",
					children : [
						{
							dataField : "a_total_qty",
							headerText : "수량",
							width : "45",
							minWidth : "20",
							style : "aui-center",
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								return value == "0"? "" : $M.setComma(value);
							},
							styleFunction : CustomStyleFunction,
						},
						{
							dataField : "a_total_rate",
							headerText : "비율",
							postfix : "%",
							headerStyle : "aui-fold",
							width : "50",
							minWidth : "20",
							style : "aui-center",
							// [14512] 기간내 비율항목에 막대그래프 표시 - 작성자 김경빈
							renderer : {
								type : "BarRenderer",
								min : 0,
								max : 100
							},
						}
					]
				},
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);

			for (var i = 0; i < areaList.length; ++i) {
				var result = areaList[i];
				var dataFiledName = "a_" + String(result.sale_area_code).toLowerCase() + "_qty";
				var rateFiledName = "a_" + String(result.sale_area_code).toLowerCase() + "_rate";
				var columnObj = {
					headerText : result.area_si,
					children : [
						{
							headerText : "수량",
							dataField : dataFiledName,
							width : "5%",
							style : "aui-center",
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								return value == "0"? "" : $M.setComma(value);
							},
							styleFunction : CustomStyleFunction,
						},
						{
							headerText : "비율",
							dataField : rateFiledName,
							postfix : "%",
							width : "5%",
							headerStyle : "aui-fold",
							style : "aui-center",
							// [14512] 비율항목에 막대그래프 표시 - 작성자 김경빈
							renderer : {
								type : "BarRenderer",
								min : 0,
								max : 100
							},
						}
					]
				};

				AUIGrid.addColumn(auiGrid, columnObj, 'last');
			}

// 			var colSizeList = AUIGrid.getFitColumnSizeList(auiGrid, true);
// 			// 구해진 칼럼 사이즈를 적용 시킴.
// 			AUIGrid.setColumnSizeList(auiGrid, colSizeList);

			$("#auiGrid").resize();
			
			// 펼치기 전에 접힐 컬럼 목록
			var auiColList = AUIGrid.getColumnInfoList(auiGrid);
			
			for (var i = 0; i <auiColList.length; ++i) {
				if (auiColList[i].headerStyle != null && auiColList[i].headerStyle == "aui-fold") {
					dataFieldName.push(auiColList[i].dataField);
				}
			}
			
			for (var i = 0; i < dataFieldName.length; ++i) {
				var dataField = dataFieldName[i];
				AUIGrid.hideColumnByDataField(auiGrid, dataField);
			}

			AUIGrid.bind(auiGrid, "cellClick", function(event) {

				var startDt = fnSetDate($M.getValue("s_start_year"), $M.getValue("s_start_mon"));
				var endDt = fnSetDate($M.getValue("s_end_year"), $M.getValue("s_end_mon"));

				if (event.headerText == "규격" || event.headerText == "메이커" || event.value == "" || event.item.ms_machine_sub_type_name.includes("총계")) {
					return;
				}

				// 지역이름
				var areaSi = areaList[((event.columnIndex - 4) / 2 ) - 1];
				if ($.isEmptyObject(areaSi)) {
					areaSi = "total";
				} else {
					areaSi = areaSi.area_si;
				}

				// 보낼 데이터
				var params = {
					"s_menu_type" : "center",
					"s_center_org_code" : $M.getValue("s_center_org_code"), // 센터 코드
					"s_sale_mem_no" : $M.getValue("s_sale_mem_no"), // 담당자 코드
					"s_area_code_str" : areaSi,
					"s_ms_mon" : startDt + "#" + endDt,
					"s_sub_type_cd" : event.item.ms_machine_sub_type_cd, // 규격코드
					"s_ms_machine_type_cd" : $M.getValue("s_ms_machine_type_cd") // 기종
				};

				// 메이커별 소계는 미니굴삭기의 규격코드 0102, 0103, 0104만 포함
				if (event.item.ms_machine_sub_type_name.includes("소계 ]")) {
					params.s_sub_type_cd = "0102#0103#0104";
				}

				if (event.item.maker_cd === "---") { // 기타 (선택된 메이커를 제외한 모든 메이커)
					params.s_select_type = "etc";
					params.s_maker_cd_str = $M.getValue("s_maker_cd");
				} else if (event.item.maker_cd.length < 4) { // 정상 메이커 코드
					params.s_select_type = "detail";
					params.s_maker_cd_str = event.item.maker_cd;
				} else {
					params.s_select_type = "total";
					params.s_maker_cd_str = $M.getValue("s_maker_cd");
				}

				$M.goNextPage('/sale/sale0501p01', $M.toGetParam(params), {popupStatus : ""});
			});
		}
		
        // 기종에 따른 메이커 조회
        function goSearchMakerList() {
        	var param = {
        			s_ms_machine_type_cd : $M.getValue("s_ms_machine_type_cd")
        	}
        	
			$M.goNextPageAjax("/sale/sale0501/search/maker", $M.toGetParam(param), {method: "GET"},
				function (result) {
					if (result.success) {
						console.log("result : ", result);
						
						$("#s_maker_cd").combogrid({
							panelWidth: "300",
							idField: "code_value",
							textField : "code_name",
						});
						
						// 콤보그리드 다시 세팅
						$("#s_maker_cd").combogrid("grid").datagrid("loadData", result.makerList);

						var msMakerCd = result.defaultMakerCd;
						var msMakerCdArr = msMakerCd.split("#");

						$('#s_maker_cd').combogrid("setValues", msMakerCdArr);
					}
				}
			);
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

		function CustomStyleFunction(rowIndex, columnIndex, value, headerText, item, dataField) {
			if (!item.ms_machine_sub_type_name.includes("총계")) {
				return (item.ms_machine_sub_type_name.includes("소계 ]")) ? "aui-sub-total-popup" : "aui-popup";
			}
			return null;
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
<!-- 기본 -->					
					<div class="search-wrap">
						<table class="table">
							<colgroup>
								<col width="65px">
								<col width="350px">
								<col width="45px">
								<col width="100px">
								<col width="45px">
								<col width="100px">
								<col width="55px">
								<col width="100px">
								<col width="55px">
								<col width="400px">
							</colgroup>
							<tbody>
								<tr>								
									<th>조회년월</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-3">
												<select class="form-control" id="s_start_year" name="s_start_year">
													<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
														<option value="${i}" <c:if test="${i==inputParam.s_start_year}">selected</c:if>>${i}년</option>
													</c:forEach>
												</select>
											</div>
											<div class="col-2">
												<select class="form-control" id="s_start_mon" name="s_start_mon">
													<c:forEach var="i" begin="1" end="12" step="1">
														<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i==inputParam.s_start_mon}">selected</c:if>>${i}월</option>
													</c:forEach>
												</select>
											</div>
											<div class="col-auto text-center">~</div>
											<div class="col-3">
												<select class="form-control" id="s_end_year" name="s_end_year">
													<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
														<option value="${i}" <c:if test="${i==inputParam.s_end_year}">selected</c:if>>${i}년</option>
													</c:forEach>
												</select>
											</div>
											<div class="col-3">
												<select class="form-control" id="s_end_mon" name="s_end_mon">
													<c:forEach var="i" begin="1" end="12" step="1">
														<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i==inputParam.s_end_mon}">selected</c:if>>${i}월</option>
													</c:forEach>
												</select>
											</div>
										</div>
									</td>
									<th>센터</th>
									<td>
										<select class="form-control" id="s_center_org_code" name="s_center_org_code">
											<option value="">- 전체 - </option>
											<c:forEach items="${warehouseList}" var="item">
												<option value="${item.center_org_code}" <c:if test="${item.center_org_code == inputParam.s_center_org_code}">selected="selected"</c:if> >${item.center_org_name}</option>
											</c:forEach>
										</select>
									</td>
									<th>담당자</th>
									<td>
										<select class="form-control" id="s_sale_mem_no" name="s_sale_mem_no">
											<option value="">- 전체 - </option>
											<c:forEach items="${saleMemList}" var="item">
												<option value="${item.sale_mem_no}">${item.sale_mem_name}</option>
											</c:forEach>
										</select>
									</td>
									<th>기종</th>
									<td>
										<select class="form-control" id="s_ms_machine_type_cd" name="s_ms_machine_type_cd" onchange="goSearchMakerList()">
											<c:forEach items="${codeMap['MS_MACHINE_TYPE']}" var="item">
												<option value="${item.code_value}">${item.code_name}</option>
											</c:forEach>
										</select>
									</td>
									<th>메이커</th>
									<td>
										<input class="form-control" style="width: 99%;" type="text" id="s_maker_cd" name="s_maker_cd" easyui="combogrid"
											   easyuiname="makerList" panelwidth="300" idfield="code_value" textfield="code_name" multi="Y"/>
									</td>
									<td class="">
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
									</td>
								</tr>								
							</tbody>
						</table>
					</div>
<!-- /기본 -->	
<!-- 조회결과 -->
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
					<div id="auiGrid" style="margin-top: 5px; height: 650px"></div>
<!-- /조회결과 -->					
				</div>
						
			</div>		
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
		</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>