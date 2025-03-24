<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 장비 입/출고 > 장비입고관리 > null > null
-- 작성자 : 최보성
-- 최초 작성일 : 2020-04-07 19:54:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	<%-- 여기에 스크립트 넣어주세요. --%>
	
	var auiGrid;
	var requireInListCnt = ${requireInListCnt};
	var dataFieldName = []; // 펼침 항목(create할때 넣음)
	
	$(document).ready(function() {
		// AUIGrid 생성
		createAUIGrid();
		fnInit();
		goSearch();		
		
	});
	

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
	}
	
	
	function fnInit() {
// 		var now = "${inputParam.s_current_dt}";
// 		$M.setValue("s_start_dt", $M.addMonths($M.toDate(now), -1));
// 		$M.setValue("s_end_dt", $M.toDate(now));
		if(${page.add.MACHINE_IN_MNG_YN eq 'Y'}){
			if(requireInListCnt != "0"){
				var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=750, left=0, top=0";
				$M.goNextPage('/serv/serv0201p01', "", {popupStatus : popupOption});
			}
		}
	}
	
	function goCenterConfirm(){
	
		//if(${page.add.MACHINE_IN_MNG_YN eq 'Y'}){
// 			if(requireInListCnt != "0"){
				var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=700, left=0, top=0";
				$M.goNextPage('/serv/serv0201p01', "", {popupStatus : popupOption});
// 			}
		//}else {
		//	alert("조회 권한이 없습니다.");
		//}
	}
	//그리드생성
	function createAUIGrid() {
		var gridPros = {
			rowIdField : "_$uid",
			showRowNumColumn : true,
			treeColumnIndex : 1,
			displayTreeOpen : true,
			enableFilter :true,
			height : 550,
			headerHeight : 40
		};
		
		var columnLayout = [
// 			{ 
// 				headerText : "등록일",
// 				dataField : "reg_date",
// 				style : "aui-center",
// 				dataType : "date",  
// 				formatString : "yy-mm-dd",
// 				width : "75",
// 				minWidth : "75",
// 			},
			{ 
				headerText : "입고예정일", 
				dataField : "center_in_plan_dt",
				style : "aui-center",
				dataType : "date",
				formatString : "yy-mm-dd",
				width : "85",
				minWidth : "85",
			},
			{ 
				headerText : "관리번호<br>(컨테이너정보)",
				dataField : "machine_no",
				width : "150",
				minWidth : "150",
				style : "aui-center",
				styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if (item["seq_depth"] == "1") {
						return "aui-popup"
					}
					return null;
				},
				filter : {
					showIcon : true
				},
				labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
					if (item["seq_depth"] == "1") {
						return value.substring(7);
					}
					return value;
				}
			},
			{ 
				headerText : "발주내역",
				dataField : "machine_name",
				width : "230",
				minWidth : "230",
				style : "aui-left",
			},
			{ 
				headerText : "발주처",
				dataField : "client_cust_name",
				style : "aui-center",
				width : "120",
				minWidth : "120",
			},
			{ 
				headerText : "참고",
				dataField : "desc_text", 
				headerStyle : "aui-fold",
				width : "250",
				minWidth : "250",
				style : "aui-left",
				labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
					var desc_text = value;
					if(item["seq_depth"] != "1") {
						desc_text = "-"
					}
					return desc_text;
				}
			},
			/* { 
				headerText : "컨테이너명", 
				dataField : "container_name", 
				style : "aui-center",
			}, */
			{ 
				headerText : "입고요청",
				dataField : "center_org_name", 
				style : "aui-center",
				width : "80",
				minWidth : "80",
			},
			{ 
				headerText : "입고확정",
				dataField : "in_org_name", 
				style : "aui-center",
				width : "80",
				minWidth : "80",
			},
			{ 
				headerText : "상태",
				dataField : "status_name",
				style : "aui-center",		
				headerStyle : "aui-fold",		
				width : "70",
				minWidth : "70",
			},
			{ 
				headerText : "센터<br>요청여부",
				dataField : "center_confirm_req_yn",
				style : "aui-center",				
				width : "60",
				minWidth : "60",
				labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
					var desc_text = value;
					if(item["seq_depth"] == "2" && item["center_confirm_req_yn"] == "Y") {
						desc_text = "요청"
					} else if (item["seq_depth"] == "1") {
						desc_text = "-"
					} else {
						desc_text = "미요청"
					}
					return desc_text;
				}
				
			},
			{ 
				headerText : "센터<br>확정여부",
				dataField : "center_confirm_yn",
				style : "aui-center",				
				width : "60",
				minWidth : "60",
				labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
					var desc_text = value;
					if(item["seq_depth"] == "2" && item["center_confirm_yn"] == "Y") {
						desc_text = "확정"
					} else if (item["seq_depth"] == "1") {
						desc_text = "-"
					} else {
						desc_text = "미확정"
					}
					return desc_text;
				}
				
			},
			{ 
				headerText : "입고일자",
				dataField : "in_proc_date",
				style : "aui-center",
				dataType : "date",
				formatString : "yy-mm-dd",				
				width : "85",
				minWidth : "85",
			},
			{
				dataField : "machine_lc_no",
				visible : false
			}
		];
		
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		AUIGrid.setGridData(auiGrid, []);
		//AUIGrid.setGridData(auiGrid, testData);
		
		AUIGrid.bind(auiGrid, "cellClick", function(event) {
			if(event.dataField == "machine_no" ) {
				if(event.item.seq_depth == "1") {
					var params = {
						machine_lc_no : event.item.machine_lc_no	
					};
					var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=750, left=0, top=0";
					$M.goNextPage('/serv/serv0201p02', $M.toGetParam(params), {popupStatus : popupOption});
				}
			}
		});	
		
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
		
		$("#auiGrid").resize();
		
		
	}
	
	// 조회
	function goSearch() {
		if($M.getValue("s_start_dt") != "" && $M.getValue("s_end_dt") != ""){
			if($M.checkRangeByFieldName("s_start_dt", "s_end_dt", true) == false) {				
				return;
			}
		}
		var param = {
				s_machine_lc_status : $M.getValue("s_machine_lc_status")
				, s_start_dt : $M.getValue("s_start_dt")
				, s_end_dt : $M.getValue("s_end_dt")
		}
		_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
			function(result){
				if(result.success) {
					$("#total_cnt").html(result.total_cnt);
					AUIGrid.setGridData(auiGrid, result.list);
				}
			}
		); 
	}
	
	function fnDownloadExcel() {
		// 엑셀 내보내기 속성
	 	var exportProps = {
			//제외항목
		};
		fnExportExcel(auiGrid, "장비입고관리", exportProps);
  	}
	
	// 보유장비현황 팝업 호출
	function goMachineDetail() {
		var param = {
// 			"s_machine_status_cd_str": $M.getValue("s_machine_status_cd"),
// 			"s_maker_cd": $M.getValue("s_maker_cd"),
// 			"s_machine_name": $M.getValue("s_machine_name"),
// 			"s_sale_mem_no": $M.getValue("s_sale_mem_no"),
// 			"s_body_no": $M.getValue("s_body_no")
		};

		var popupOption = "";
		$M.goNextPage('/sale/sale0204p02', $M.toGetParam(param), {popupStatus: popupOption});
	}
	
	// 입고일정 (2.5차 추가)
	function goInPlanSchedule() {
		var param = {};

		var popupOption = "";
		$M.goNextPage('/sale/sale0203p09', $M.toGetParam(param), {popupStatus: popupOption});		
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
								<col width="70px">
								<col width="270px">				
								<col width="30px">
								<col width="100px">	
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th>입고예정일</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" alt="" value="${searchDtMap.s_start_dt}">
<!-- 													<button type="button" class="btn btn-icon btn-primary-gra"><i class="material-iconsdate_range"></i></button> -->
												</div>
											</div>
											<div class="col-auto">~</div>
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="" value="${searchDtMap.s_end_dt}">
<!-- 													<button type="button" class="btn btn-icon btn-primary-gra"><i class="material-iconsdate_range"></i></button> -->
												</div>
											</div>
											<jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp">
				                     		<jsp:param name="st_field_name" value="s_start_dt"/>
				                     		<jsp:param name="ed_field_name" value="s_end_dt"/>
				                     		<jsp:param name="click_exec_yn" value="Y"/>
				                     		<jsp:param name="exec_func_name" value="goSearch();"/>
				                     		</jsp:include>	
										</div>
									</td>
									<th>상태</th>
									<td>
										<select id="s_machine_lc_status" name="s_machine_lc_status" class="form-control">
											<option value="">- 전체 -</option>
											<c:forEach items="${codeMap['MACHINE_LC_STATUS']}" var="item">
												<c:if test="${item.code_value ne '01'}"> 
													<option value="${item.code_value}">${item.code_name}</option>
												</c:if>
											</c:forEach>
										</select>
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
								<label for="s_toggle_column" style="color:black;">
									<input type="checkbox" id="s_toggle_column" onclick="javascript:fnChangeColumn(event)">펼침
								</label>
								<button type="button" class="btn btn-important" style="width: 80px;" onclick="javascript:goMachineDetail();">보유장비현황</button>
								<button type="button" onclick=AUIGrid.expandAll(auiGrid); class="btn btn-default"><i class="material-iconsadd text-default"></i>전체펼치기</button>
								<button type="button" onclick=AUIGrid.collapseAll(auiGrid); class="btn btn-default"><i class="material-iconsremove text-default"></i>전체접기</button>							
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->	
					<div id="auiGrid" style="margin-top: 5px; height: 550px;"></div>
					<div class="btn-group mt5">	
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">0</strong>건
						</div>
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