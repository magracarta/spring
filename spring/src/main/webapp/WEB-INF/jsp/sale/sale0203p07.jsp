<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 장비관리 > 장비입고-LC Open 선적 > null > 입고센터지정
-- 작성자 : 황빛찬
-- 최초 작성일 : 2021-08-09 17:17:08
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
	var auiGrid;
	var centerList = ${centerList}

	$(document).ready(function() {
		createAUIGrid(); // 메인 그리드
		goSearch();
	});
	
	function createAUIGrid() {
		var gridPros = {
			rowIdField : "_$uid", 
			// rowNumber 
			showRowNumColumn: true,
			showStateColumn : true,
			treeColumnIndex : 7,
			displayTreeOpen : true,
			enableFilter :true,
			editable : true,
		};
		var columnLayout = [
			{
				dataField : "container_seq",
				visible : false
			},
			{ 
				headerText : "메이커", 
				dataField : "maker_name", 
				width : "110", 
				style : "aui-center",
				editable : false
			},
			{ 
				headerText : "LC번호", 
				dataField : "machine_lc_no", 
				width : "70", 
				style : "aui-center",
				editable : false,
				labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
					if (item["seq_depth"] == "1") {
						return value.substring(4);
					} else {
						return "";
					}
				}
			},
			{ 
				headerText : "ETD", 
				dataField : "etd", 
				width : "70", 
				style : "aui-center",
				dataType : "date",   
				formatString : "yy-mm-dd",
				editable : false
			},
			{ 
				headerText : "ETA", 
				dataField : "eta", 
				width : "70", 
				style : "aui-center",
				dataType : "date",   
				formatString : "yy-mm-dd",
				editable : false
			},
			{ 
				headerText : "센터입고일", 
				dataField : "center_in_plan_dt", 
				width : "100", 
				style : "aui-center",
				dataType : "date",   
				formatString : "yyyy-mm-dd",
				dataInputString : "yyyymmdd",
				editable : true,
				editRenderer : {
					type : "JQCalendarRenderer", // datepicker 달력 렌더러 사용
					defaultFormat : "yyyymmdd", // 원래 데이터 날짜 포맷과 일치 시키세요. (기본값: "yyyy/mm/dd")
					onlyCalendar : true, // 사용자 입력 불가, 즉 달력으로만 날짜입력 ( 기본값: true )
					maxlength : 8,
					onlyNumeric : true, // 숫자만
					validator : function(oldValue, newValue, rowItem) { // 에디팅 유효성 검사
						return fnCheckDate(oldValue, newValue, rowItem);
					},
					showEditorBtnOver : true
				},
				styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if (item.center_confirm_req_yn == "N") {
						return "aui-editable";
					} else {
						return "";
					};
				},
			},
			{ 
				headerText : "요일", 
				dataField : "day", 
				width : "60", 
				style : "aui-center",
				editable : false
			},
			{ 
				headerText : "컨테이너", 
				dataField : "container_name", 
				width : "170", 
				style : "aui-center",
				editable : false
			},
			{ 
				headerText : "모델명", 
				dataField : "machine_name", 
				width : "210", 
				style : "aui-left",
				editable : false
			},
			{ 
				headerText : "합계", 
				dataField : "qty", 
				width : "60", 
				style : "aui-center",
				dataType : "numeric",
				formatString : "#,##0",
				editable : false
			},
			{ 
				headerText : "입고희망센터", 
				dataField : "center_org_code", 
				width : "90", 
				style : "aui-center",
				editable : true,
				editRenderer : {				
					type : "DropDownListRenderer",
					list : centerList,
					keyField : "org_code",
					valueField : "org_name"
				},
				labelFunction : function(rowIndex, columnIndex, value){
					for(var i=0; i<centerList.length; i++){
						if(value == centerList[i].org_code){
							return centerList[i].org_name;
						}
					}
					return value;
				},
				styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if (item.center_confirm_req_yn == "N") {
						return "aui-editable";
					} else {
						return "";
					};
				},
			},
			{ 
				headerText : "요청여부", 
				dataField : "center_confirm_req_yn", 
				width : "55", 
				style : "aui-center",
				editable : false
			},
			{ 
				headerText : "확정여부", 
				dataField : "center_confirm_yn", 
				width : "55", 
				style : "aui-center",
				editable : false
			},
			{ 
				headerText : "입고결정", 
				dataField : "requestBtn", 
				width : "70", 
				style : "aui-center",
				editable : false,
				renderer : {
					type : "ButtonRenderer",
					onClick : function(event) {
						// 센터 미확정일 경우
						if (event.item.center_confirm_yn == "N") {
							// 벨리데이션 체크
							var conList = event.item.children;  // 요청한 LC의 컨테이너 리스트
							for (var i = 0; i < conList.length; i++) {
								if (conList[i].qty == 0) {
									alert("LC번호 : " + event.item.machine_lc_no.substring(4) + "\n장비 선적이 미완료된 컨테이너가 있습니다.\n컨테이너에 장비 선적 후 요청 해 주세요.");
									return;
								}
							}
							
							// 센터입고일 체크
// 							if (event.item.center_in_plan_dt == "") {
// 								AUIGrid.showToastMessage(auiGrid, event.rowIndex, 5, "센터 입고일을 입력해주세요.");
// 								return;
// 							}
							
							// 입고희망센터 체크
							for (var i = 0; i < conList.length; i++) {
								if (conList[i].center_in_plan_dt == "") {
									AUIGrid.showToastMessage(auiGrid, (event.rowIndex + i+1), 5, "센터 입고일을 입력해주세요.");
									return;
								}

								if (conList[i].center_org_code == "") {
									AUIGrid.showToastMessage(auiGrid, (event.rowIndex + i+1), 10, "입고희망센터를 입력해주세요.");
									return;
								}
								
							}
							
							var msg = "";
							if (event.item.center_confirm_req_yn == "Y") {
								msg = "입고센터 요청취소 하시겠습니까 ?\n센터입고일과 입고희망센터가 초기화됩니다.";								
							} else {
								msg = "입고센터 요청 하시겠습니까 ?";								
							}
							
							if (confirm(msg) == false) {
								return;
							}
							
							var containerSeqArr = [];  // 컨테이너번호
							var centerOrgCodeArr = [];  // 입고희망센터
							var centerInPlanDtArr = [];  // 센터입고일자
							var centerConfirmReqYnArr = []; // 요청여부
							
							for (var i = 0; i < conList.length; i++) {
								containerSeqArr.push(conList[i].container_seq);
								centerOrgCodeArr.push(conList[i].center_org_code);
// 								centerInPlanDtArr.push(event.item.center_in_plan_dt);
								centerInPlanDtArr.push(conList[i].center_in_plan_dt);
								centerConfirmReqYnArr.push(event.item.center_confirm_req_yn);
							}
							
							var option = {
									isEmpty : true
							};
							
							var param = {
									container_seq_str : $M.getArrStr(containerSeqArr, option),
									center_org_code_str : $M.getArrStr(centerOrgCodeArr, option),
									center_in_plan_dt_str : $M.getArrStr(centerInPlanDtArr, option),
									center_confirm_req_yn_str : $M.getArrStr(centerConfirmReqYnArr, option),
							}
							console.log("param : ", param);
							
							// 요청, 요청취소 처리
							$M.goNextPageAjax(this_page +"/proc", $M.toGetParam(param), {method : 'POST'}, 
				   				function(result) {
				   					if(result.success) {
// 										window.opener.location.reload();
				   						location.reload();
				   					};
				   				}
				   			);
							
						} else {
							// 센터확정일 경우
							alert("센터확정이 완료된 컨테이너입니다.");
						}
						
					},
					visibleFunction : function(rowIndex, columnIndex, value, item, dataField ) {
						// 요청 / 요청취소버튼은 LC단위에만 보여지도록함.
						if(item.seq_depth == "1") {
						  	return true;
						} else {
						  	return false;
						}	
					}
				},
				labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
					if (item.seq_depth == "1") {
						if (item["center_confirm_req_yn"] == 'Y') {
							if (item["center_confirm_yn"] == "Y") {
								return '확정완료'
							} else {
								return '요청취소'
							}
						} else {
							return '요청'
						}
					} 
				},
			},
		];
		
		// 실제로 #grid_wrap 에 그리드 생성
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		// 그리드 갱신
		AUIGrid.setGridData(auiGrid, []);
		
		AUIGrid.bind(auiGrid, "cellEditBegin", function (event) {
// 			console.log("evnet : ", event);
			
			// LC 뎁스는 입고희망센터 수정 불가
			if (event.item.seq_depth == "1") {
				if (event.dataField == "center_org_code") {
					return false;
				}
			}
			
			// 컨테이너 뎁스는 센터입고일 수정 불가
			// 2021-09-23 (SR : 12730) 컨테이너도 센터입고일 수정 가능하도록 수정.
// 			if (event.item.seq_depth == "2") {
// 				if (event.dataField == "center_in_plan_dt") {
// 					return false;
// 				}
// 			}
			
			if (event.item.center_confirm_req_yn == 'Y') {
				if (event.dataField == "center_org_code" || event.dataField == "center_in_plan_dt") {
					return false;
				}
			}
		});
		
		AUIGrid.bind(auiGrid, "cellEditEnd", function (event) {
			if (event.dataField == "center_in_plan_dt") {
				var conList = event.item.children;
				if (conList != undefined) {
					for (var i = 0; i < conList.length; i++) {
						AUIGrid.updateRow(auiGrid, {"center_in_plan_dt" : event.value}, (event.rowIndex + i+1));
					}
				}
				
				// 센터입고일 변경시 요일 세팅
				var param = {
						center_in_plan_dt : event.value
				}
				
				$M.goNextPageAjax(this_page + "/getDayOfWeek", $M.toGetParam(param), {method : 'get'},
					function(result) {
						if(result.success) {
							console.log(result);
							AUIGrid.updateRow(auiGrid, {"day" : result.dayOfWeek+"요일"}, event.rowIndex);
							
							if (conList != undefined) {
								for (var i = 0; i < conList.length; i++) {
									AUIGrid.updateRow(auiGrid, {"day" : result.dayOfWeek+"요일"}, (event.rowIndex + i+1));
								}
							}
							
						};
					}		
				);
				
			}
		});
		
		
	}	

	// 센터 별 보유장비현황 팝업
	function goMachineDetail() {
		var params = {};
		var popupOption = "";
		// 장비입고-LC Open선적 입고센터지정 팝업
		$M.goNextPage('/sale/sale0203p08', $M.toGetParam(params), {popupStatus : popupOption});
	}
	
	// 액셀다운로드
	function fnDownloadExcel() {
		fnExportExcel(auiGrid, "입고센터지정");
	}
	
	// 저장
	function goSave() {
		var changeGridData = AUIGrid.getEditedRowItems(auiGrid);
		console.log(changeGridData);
		
		if (changeGridData.length == 0) {
			alert("변경된 내역이 없습니다.");
			return;
		}
		
		if (confirm("저장 하시겠습니까?") == false) {
			return;
		}
		
		var containerSeqArr = [];  // 컨테이너번호
		var centerOrgCodeArr = [];  // 입고희망센터
		var centerInPlanDtArr = [];  // 센터입고일자
		var machineLcNoArr = []; // 요청여부
		
		for (var i = 0; i < changeGridData.length; i++) {
			if (changeGridData[i].seq_depth == "2") {
				containerSeqArr.push(changeGridData[i].container_seq);
				centerOrgCodeArr.push(changeGridData[i].center_org_code);
				centerInPlanDtArr.push(changeGridData[i].center_in_plan_dt);
			}
		}
		
		var option = {
				isEmpty : true
		};
		
		var param = {
				container_seq_str : $M.getArrStr(containerSeqArr, option),
				center_org_code_str : $M.getArrStr(centerOrgCodeArr, option),
				center_in_plan_dt_str : $M.getArrStr(centerInPlanDtArr, option),
		}
		console.log("param : ", param);

		// 저장
		$M.goNextPageAjax(this_page +"/modify", $M.toGetParam(param), {method : 'POST'}, 
			function(result) {
				if(result.success) {
// 					window.opener.location.reload();
					location.reload();
				};
			}
		);
	}
	
	// 닫기
	function fnClose() {
		window.close();
	}
	
	// 모델조회
	function fnSettingMachine(data) {
		$M.setValue("s_machine_name", data.machine_name);
	}
	
	// 조회
	function goSearch() {
		var param = {
				s_date_type : $M.getValue("s_date_type"),
				s_start_dt : $M.getValue("s_start_dt"),
				s_end_dt : $M.getValue("s_end_dt"),
				s_machine_name : $M.getValue("s_machine_name")
			};
		_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
			function(result) {
				if(result.success) {
					$("#total_cnt").html(result.total_cnt);
					AUIGrid.setGridData(auiGrid, result.list);
				};
			}		
		);		
	}
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
<!-- 폼테이블 -->					
			<div>					
<!-- 검색영역 -->					
				<div class="search-wrap mt5">
					<table class="table">
						<colgroup>
								<col width="0px">
								<col width="100px">
								<col width="270px">
								<col width="60px">
								<col width="200px">
						</colgroup>
						<tbody>
							<tr>
								<th></th>
								<td>
									<select name="s_date_type" id="s_date_type" class="form-control width100px">
										<option value="etd">ETD</option>
										<option value="eta">ETA</option>
										<option value="center_in_plan_dt">센터입고일</option>
									</select>
								</td>
								<td>
									<div class="form-row inline-pd">
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 essential-bg calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" alt="시작일" value="${searchDtMap.s_start_dt}">
											</div>
										</div>
										<div class="col-auto">~</div>
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 essential-bg calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="종료일" value="${searchDtMap.s_end_dt}">
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
								<th>모델명</th>
								<td>
									<jsp:include page="/WEB-INF/jsp/common/searchMachine.jsp">
										<jsp:param name="required_field" value="s_machine_name"/>
										<jsp:param name="s_maker_cd" value=""/>
										<jsp:param name="s_machine_type_cd" value=""/>
										<jsp:param name="s_sale_yn" value=""/>
										<jsp:param name="readonly_field" value=""/>
										<jsp:param name="execFuncName" value="fnSettingMachine"/>
									</jsp:include>
								</td>
								<td class=""><button type="button" class="btn btn-important" style="width: 55px;" onclick="javascript:goSearch();">조회</button></td>
							</tr>
						</tbody>
					</table>
				</div>
<!-- /검색영역 -->
<!-- 조회결과 -->
				<div class="title-wrap mt10">
					<h4>조회결과</h4>
					<div class="btn-group">
						<div class="right">
							<button type="button" onclick=AUIGrid.expandAll(auiGrid); class="btn btn-default"><i class="material-iconsadd text-default"></i>전체펼치기</button>
							<button type="button" onclick=AUIGrid.collapseAll(auiGrid); class="btn btn-default"><i class="material-iconsremove text-default"></i>전체접기</button>
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
						</div>
					</div>
				</div>
				<div id="auiGrid" style="margin-top: 5px; height: 450px;"></div>
<!-- /조회결과 -->
			</div>		
<!-- /폼테이블 -->
			<div class="btn-group mt10">
				<div class="left">
					총 <strong id="total_cnt" class="text-primary">0</strong>건
				</div>	
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>