<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 판매관리 > 장비판매현황-판매점별 > null > null
-- 작성자 : 정선경
-- 최초 작성일 : 2024-04-29 16:51:10
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var auiGrid;
		var yearMonList 	= [];
		var splitParam 		= '<br/> /';
		var fieldPrefix 	= "month";
		var machineGroupByMaker = ${machineGroupByMaker};
		var machineList = ${machineList};
		var isOpen = false;
		var searchList;
		var dataFieldName = []; // 펼침 항목(create할때 넣음)

		$(document).ready(function() {
			goSearch();
		});

		// 조회
		function goSearch() {
			var s_month = $M.getValue("s_month");
			var s_from_month = $M.getValue("s_from_month");

			if(s_month.toString().length == 1) {
				s_month = '0' + s_month;
			}
			if(s_from_month.toString().length == 1){
				s_from_month = '0' + s_from_month;
			}

			var param = {
				"s_year_mon"  				: $M.getValue("s_year") + s_month,
				"s_from_year_mon"     		: $M.getValue("s_from_year") + s_from_month,
				"s_agency_code" 			: $M.getValue("s_agency_code"),
				"s_agency_org_code"			: $M.getValue("s_agency_org_code"),
				"s_agency_org_mem_no" 		: $M.getValue("s_agency_org_mem_no"),
				"s_maker_cd" 				: $M.getValue("s_maker_cd"),
				"s_machine_plant_seq_str"	: $M.getValue("s_machine_plant_seq"),
			};
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
					function(result) {
						if(result.success) {
							$("#total_cnt").html(result.total_cnt);
							dataFieldName = [];
							yearMonList = result.months;
							searchList = result.list;

							destroyGrid();
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
		}

		//그리드생성
		function createAUIGrid() {
			var totalFieldArr = [];
			for(var i = 0; i < yearMonList.length; ++i) {
				totalFieldArr.push(fieldPrefix + [i+1]);
			}

			var gridPros = {
				rowIdField : "_$uid",
				headerHeight : 40,
				height : 565,
				showRowNumColumn : false,
				useGroupingPanel : false,
				showBranchOnGrouping : false,
				displayTreeOpen : true,
				enableCellMerge : true,
				rowStyleFunction : function(rowIndex, item) {
					if(item.agency_org_name.indexOf("합계") > -1 || item.agency_name.indexOf("합계") > -1) {
						return "aui-grid-row-depth3-style";
					}
					return null;
				}
			};

			var columnLayout = [
				{
					headerText : "부문",
					dataField : "agency_name",
					width : "110",
					minWidth : "85",
					style : "aui-center",
					cellMerge : true,
				},
				{
					headerText : "위탁판매점명",
					dataField : "agency_org_name",
					width : "150",
					minWidth : "85",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if(value.indexOf("합계") != -1 ) {
							return "aui-center";
						}
						return "aui-left";
					},
				},
				{
					headerText : "대표자명",
					dataField : "breg_rep_name",
					width : "100",
					minWidth : "85"
				},
				{
					headerText : "연계",
					dataField : "total",
					width : "65",
					minWidth : "85",
					style : "aui-right",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if(value > 0) {
							return "aui-popup";
						}
					},
					expFunction : function(  rowIndex, columnIndex, item, dataField ) {
						var sumValue = 0;
						if(isOpen){
							for (var i = 0; i < totalFieldArr.length; ++i) {
								sumValue += $M.toNum(item[totalFieldArr[i]]);
							}
						}else{
							for (var i = 0; i < totalFieldArr.length-12; ++i) {
								sumValue += $M.toNum(item[totalFieldArr[i]]);
							}
						}
						return isNaN(sumValue) ? 0 : sumValue;
					},
				},
				{
					headerText : "st_year_mon",
					dataField : "st_year_mon",
					visible : false,
					expFunction : function(  rowIndex, columnIndex, item, dataField ) {
						var idx = totalFieldArr.length;
						if(!isOpen){
							idx = totalFieldArr.length-12
						}
						var headerText = AUIGrid.getColumnItemByDataField(auiGrid, "month"+idx).headerText;
						return headerText.replace(splitParam, '');
					},
				},
				{
					headerText : "ed_year_mon",
					dataField : "ed_year_mon",
					visible : false,
					expFunction : function(  rowIndex, columnIndex, item, dataField ) {
						var headerText = AUIGrid.getColumnItemByDataField(auiGrid, "month1").headerText;
						return headerText.replace(splitParam, '');
					},
				},
			];

			var fieldNum = 0;
			for (var i = 0; i < yearMonList.length; ++i) {
				fieldNum += 1;
				var fieldName = fieldPrefix + fieldNum;
				var obj = {
					headerText : yearMonList[i].substr(0,4) + splitParam + yearMonList[i].substr(5,2),
					dataField : fieldName,
					width : "4%",
					style : "aui-right",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if(value == 0) {
							return "aui-grid-row-depth3-style";
						}
						return "aui-popup"
					},
				}

				var s_month =  $M.getValue("s_from_month");
				if(s_month.toString().length == 1) {
					s_month = '0' + s_month;
				}
				var searchDate = $M.getValue("s_from_year") + s_month;
				var gridDate = yearMonList[i].substr(0,4) + yearMonList[i].substr(5,2);
				if ($M.dateFormat($M.toDate(searchDate), 'yyyyMM') > gridDate) {
					obj.headerStyle = "aui-fold";
				}

				columnLayout.push(obj);
			}

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();

			// 클릭시 팝업 그리드 호출(상세보기)
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField != 'agency_name' && event.dataField != 'agency_org_name') {
					var eventValue = $M.nvl(event.value, 0);
					if(eventValue == 0) {
						return;
					}

					var year_month = event.headerText.replace(splitParam, '');
					var param = {
						"year_mon" 				: year_month,
						"agency_code" 			: event.item.agency_code,
						"agency_org_code"		: event.item.agency_org_code,
						"agency_org_mem_no" 	: $M.getValue("s_agency_org_mem_no"),
						"maker_cd" 				: $M.getValue("s_maker_cd"),
						"machine_plant_seq_str"	: $M.getValue("s_machine_plant_seq"),
					}
					if (event.item.agency_org_name.indexOf("합계") != -1) {
						param.agency_code = event.item.agency_code == ''? $M.getValue("s_agency_code") : event.item.agency_code;
						param.agency_org_code = event.item.agency_org_code == ''? $M.getValue("s_agency_org_code") : event.item.agency_org_code;
					}
					if (event.dataField == 'total') {
						param.year_mon = "";
						param.st_year_mon = event.item.st_year_mon;
						param.ed_year_mon = event.item.ed_year_mon;
						param.agency_code = event.item.agency_code == ''? $M.getValue("s_agency_code") : event.item.agency_code;
						param.agency_org_code = event.item.agency_org_code == ''? $M.getValue("s_agency_org_code") : event.item.agency_org_code;
					}

					var popupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=700, left=0, top=0";
					$M.goNextPage('/sale/sale0410p01', $M.toGetParam(param), {popupStatus : popupOption});
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
			var target = event.target || event.srcElement;
			if(!target)	return;

			var checked = target.checked;
			isOpen = checked;

			for (var i = 0; i < dataFieldName.length; ++i) {
				var dataField = dataFieldName[i];

				if(checked) {
					AUIGrid.showColumnByDataField(auiGrid, dataField);
				} else {
					AUIGrid.hideColumnByDataField(auiGrid, dataField);
				}
			}
			AUIGrid.setGridData(auiGrid, searchList);
		}

		// 위탁판매점 조회
		function goSearchAgency(obj) {
			var param = {
				"agency_code" : obj.value
			}
			$M.goNextPageAjax(this_page + "/searchAgencyOrg", $M.toGetParam(param), {method : "get", loader: false},
					function(result) {
						if(result.success) {
							// 위탁판매점 목록 세팅
							$("select#s_agency_org_code option").remove();
							$('#s_agency_org_code').append('<option value="" >'+ "- 전체 -" +'</option>');

							var list = result.list;
							if (list != ""  && list != undefined) {
								for(i = 0; i< list.length; i++){
									var optVal = list[i].org_code;
									var optText = list[i].org_kor_name;
									$('#s_agency_org_code').append('<option value="'+ optVal +'">'+ optText +'</option>');
								}
							}
							// 위탁판매점 직원 초기화
							$("select#s_agency_org_mem_no option").remove();
							$('#s_agency_org_mem_no').append('<option value="" >'+ "- 전체 -" +'</option>');
						}
					}
			);
			goSearch();
		}

		// 위탁판매점 직원 조회
		function goSearchAgencyMem(obj) {
			var param = {
				"agency_org_code" : obj.value
			}
			$M.goNextPageAjax(this_page + "/searchAgencyMem", $M.toGetParam(param), {method : "get", loader: false},
					function(result) {
						if(result.success) {
							// 위탁판매점 직원 목록 세팅
							$("select#s_agency_org_mem_no option").remove();
							$('#s_agency_org_mem_no').append('<option value="" >' + "- 전체 -" + '</option>');

							var list = result.list;
							if (list != "" && list != undefined) {
								for (i = 0; i < list.length; i++) {
									var optVal = list[i].mem_no;
									var optText = list[i].kor_name;
									$('#s_agency_org_mem_no').append('<option value="' + optVal + '">' + optText + '</option>');
								}
							}
						}
					}
			);
			goSearch();
		}

		// 메이커 선택시 모델 목록 세팅
		function fnChangeMakerCd(obj) {
			$('#s_machine_plant_seq').combogrid("reset");

			var makerCd = obj.value;
			var list = [];
			if (makerCd != "") {
				list = machineGroupByMaker[makerCd];
				if (list == undefined || list == null) {
					list = [];
				}
			} else {
				list = machineList;
			}
			$M.reloadComboData("s_machine_plant_seq", list);

			goSearch();
		}

		//엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, '장비판매현황_판매점별');
		}
	</script>
</head>
<body>
<form id="main_form" name="main_form">
	<div class="layout-box">
		<div class="content-wrap">
			<div class="content-box">
				<div class="main-title">
					<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
				</div>
				<div class="contents">
					<div class="search-wrap">
						<table class="table">
							<colgroup>
								<col width="60px">
								<col width="280px">
								<col width="50px">
								<col width="400px">
								<col width="55px">
								<col width="120px">
								<col width="55px">
								<col width="300px">
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
															<option value="${i}" <c:if test="${i eq fn:substring(s_from_dt, 0, 4)}">selected="selected"</c:if>>${i}년</option>
														</c:forEach>
												</select>
											</div>
											<div class="col-auto">
												<select class="form-control width120px" name="s_from_month" id="s_from_month">
														<c:forEach var="i" begin="01" end="12" step="1">
															<option value="${i}" <c:if test="${i eq fn:substring(s_from_dt, 4, 6)}">selected="selected"</c:if>>${i}월</option>
														</c:forEach>
												</select>
											</div>
											<div class="col-auto">~</div>
											<div class="col-auto">
												<select class="form-control width120px" name="s_year" id="s_year">
														<c:forEach var="i" begin="2007" end="${inputParam.s_current_year}" step="1">
															<option value="${i}" <c:if test="${i eq inputParam.s_current_year}">selected="selected"</c:if>>${i}년</option>
														</c:forEach>
												</select>
											</div>
											<div class="col-auto">
												<select class="form-control width120px" name="s_month" id="s_month">
														<c:forEach var="i" begin="01" end="12" step="1">
															<option value="${i}" <c:if test="${i eq fn:substring(inputParam.s_current_mon, 4, 6)}">selected="selected"</c:if>>${i}월</option>
														</c:forEach>
												</select>
											</div>
										</div>
									</td>
									<th>부문</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-4">
												<select class="form-control" id="s_agency_code" name="s_agency_code"  onchange="javascript:goSearchAgency(this);">
													<option value="">- 전체 -</option>
													<c:forEach items="${agencyList}" var="item">
														<option value="${item.org_code}"> ${item.org_name}</option>
													</c:forEach>
												</select>
											</div>
											<div class="col-4">
												<select class="form-control" id="s_agency_org_code" name="s_agency_org_code" onchange="javascript:goSearchAgencyMem(this);">
													<option value="">- 전체 -</option>
												</select>
											</div>
											<div class="col-4">
												<select class="form-control" id="s_agency_org_mem_no" name="s_agency_org_mem_no" onchange="goSearch();">
													<option value="">- 전체 -</option>
												</select>
											</div>
										</div>
									</td>
									<th>메이커</th>
									<td>
										<select id="s_maker_cd" name="s_maker_cd" class="form-control" onchange="javascript:fnChangeMakerCd(this)">
											<option value="">- 전체 -</option>
											<c:forEach items="${codeMap['MAKER']}" var="item">
												<c:if test="${item.code_v1 eq 'Y' && item.code_v2 eq 'Y'}">
													<option value="${item.code_value}">${item.code_name}</option>
												</c:if>
											</c:forEach>
										</select>
									</td>
									<th>모델명</th>
									<td>
										<input type="text" style="width : 300px";
											   id="s_machine_plant_seq"
											   name="s_machine_plant_seq"
											   easyui="combogrid"
											   header="N"
											   easyuiname="machineList"
											   panelwidth="300"
											   maxheight="300"
											   idfield="machine_plant_seq"
											   textfield="machine_name"
											   multi="Y"
											   enter="goSearch()" />
									</td>
									<td class="">
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
									</td>
								</tr>
							</tbody>
						</table>
					</div>

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

					<div id="auiGrid" style="margin-top: 5px;"></div>

					<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">0</strong>건
						</div>
					</div>
					<!-- /그리드 서머리, 컨트롤 영역 -->
				</div>
			</div>
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
		</div>
	</div>	
</form>
</body>
</html>