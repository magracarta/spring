<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈 > 렌탈대장 > GPS관리 > null > GPS 정보상세
-- 작성자 : 김상덕
-- 최초 작성일 : 2020-05-21 20:04:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var auiGrid;
		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGrid();
		});
	
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				editable : true,	
				// rowIdField 설정
				rowIdField : "_$uid", 
				// rowIdField가 unique 임을 보장
				showRowNumColumn : true,
				enableSorting : true,
				showStateColumn : true,
				// 삭제시 취소선 (default true)
				softRemoveRowMode : false
			};
			var columnLayout = [
 				{ 
					headerText : "일자", 
					dataField : "repair_dt", 
					dataType : "date",   
					style : "aui-center",
					dataInputString : "yyyymmdd",
					formatString : "yyyy-mm-dd",
					width : "20%",
					editRenderer : {
						type : "JQCalendarRenderer", // datepicker 달력 렌더러 사용
						defaultFormat : "yyyymmdd", // 원래 데이터 날짜 포맷과 일치 시키세요. (기본값: "yyyy/mm/dd")
						onlyCalendar : false, // 사용자 입력 불가, 즉 달력으로만 날짜입력 ( 기본값: true )
						maxlength : 8,
						onlyNumeric : true, // 숫자만
						validator : function(oldValue, newValue, rowItem) { // 에디팅 유효성 검사
							return fnCheckDate(oldValue, newValue, rowItem);
						},
// 						showEditorBtnOver : true
					},
					editable : true,				
				},
				{
					headerText : "내역", 
					dataField : "repair_desc", 
					width : "25%", 
					style : "aui-left",
				},
				{ 
					headerText : "비용", 
					dataField : "repair_amt", 
					width : "15%", 
					style : "aui-right",			
					dataType : "numeric",					
					formatString : "#,##0",
					editRenderer : {
				    	type : "InputEditRenderer",
					    onlyNumeric : true,
// 				      	auiGrid : "#auiGrid",
			     	 	maxlength : 20,
				      	// 에디팅 유효성 검사
// 				      	validator : AUIGrid.commonValidator
					}	
				},
				{ 
					headerText : "비고", 
					dataField : "repair_remark", 
					width : "25%", 
					style : "aui-left",
				},
				{
					headerText : "삭제",
					dataField : "delete_btn",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
// 							var isRemoved = AUIGrid.isRemovedById(auiGrid, event.item._$uid);
// 							if (isRemoved == false) {
								AUIGrid.removeRow(event.pid, event.rowIndex);		
// 							} else {
// 								AUIGrid.restoreSoftRows(auiGrid, "selectedIndex"); 
// 							} 
						}
					},
					labelFunction : function(rowIndex, columnIndex, value,
							headerText, item) {
						return '삭제'
					}
				},
				{ 
					dataField : "gps_seq", 
					visible : false
				},
				{ 
					dataField : "seq_no", 
					visible : false
				}				
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, ${repairList});
			$("#auiGrid").resize();
		}
		
	 	// 그리드 빈값 체크
		function isValid() {
			var msg = "반드시 값을 입력해야 합니다.";
			// 기본 필수 체크
			var reqField = ["repair_dt"];
			return AUIGrid.validateGridData(auiGrid, reqField, msg);
		}
		
	  	//행추가
	    function fnAdd() {
	    	if(isValid()) {
				var row = new Object();
				row.gps_seq = '${gpsInfo.gps_seq}';
				row.seq_no = '0';
				row.repair_dt = '';
				row.repair_desc = '';
	 			row.repair_amt = '';
	 			row.repair_remark = '';
	 			row.use_yn = 'Y';
				AUIGrid.addRow(auiGrid, row, "last");
			}
	    }
	  	
	  	//수정
	    function goModify() {
	    	if($M.validation(document.main_form) == false) {
				return false;
			};
			if(!isValid()) {
				return false;
			}
			var frm = $M.toValueForm(document.main_form);
			var gridFrm = fnChangeGridDataToForm(auiGrid);
			var test = AUIGrid.getGridData(auiGrid);
			$M.copyForm(gridFrm, frm);
			$M.goNextPageAjaxSave("/rent/rent0203" + "/modify", gridFrm, {method : 'POST'},
				function(result) {
					if(result.success) {
						alert("수정되었습니다");
						fnClose();
					}
				}
			);
	    }
	  	
	  	//삭제
	    function goRemove() {
	    	if($M.validation(document.main_form) == false) {
				return false;
			};
			var frm = $M.toValueForm(document.main_form);
			$M.goNextPageAjaxRemove("/rent/rent0203" + "/remove", frm, {method : 'POST'},
				function(result) {
					if(result.success) {
						alert("삭제되었습니다");
						opener.$M.goNextPage('/rent/rent0203');
						fnClose();
					}
				}
			);
	    }
	  
	  	//닫기
	    function fnClose() {
	     	window.close();
	    }
	  	
	  	// 장비대장 팝업 호출
	  	function goSearchDeviceHisPanel() {
	  		var param = {
	  			isSearchFromGps : "Y"
	  		}
	  		openSearchDeviceHisPanel('fnSetMachineInfo', $M.toGetParam(param));
	  	}
	  	
	  	function fnSetMachineInfo(row) {
	  		var param = {
	  			body_no : row.body_no,
	  			machine_name : row.machine_name,
	  			machine_seq : row.machine_seq,
	  			machine_plant_seq : row.machine_plant_seq,
	  			engine_no_1 : row.engine_no_1,
	  			machine_center_org_code : row.center_org_code,
	  			gpsUpdateYn : "Y",
	  		}
	  		$M.setValue(param);
	  	}
	  	
		 // 사용이력
	    function goGpsHistory() {
	     	var params = {
	     		"read_only_yn" : "Y"
	     		, "gps_seq" : $M.getValue("gps_seq")
	     	};
			var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=500, left=0, top=0";
			$M.goNextPage('/rent/rent0203p02', $M.toGetParam(params), {popupStatus : popupOption});
	    }
	 
	  	//탈거
	    function goUnInst() {
			// 장비에 장착되어있는지
// 			if() {
				
// 			}
	     	var params = {
     			"gps_seq" : $M.getValue("gps_seq")
	     	};
			var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=500, left=0, top=0";
			$M.goNextPage('/rent/rent0203p02', $M.toGetParam(params), {popupStatus : popupOption});
	    }
	  	
	 	// 업무DB 연결 함수 21-08-05이강원
     	function openWorkDB(){
     		openWorkDBPanel('',${gpsInfo.machine_plant_seq});
     	}
	  	
	</script>
</head>
<body  class="bg-white"   >
<form id="main_form" name="main_form">
<input type="hidden" id="gps_seq" name="gps_seq" value="${gpsInfo.gps_seq}">
<input type="hidden" name="gpsUpdateYn" value="N">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">	
			<div class="title-wrap">
				<h4>GPS정보상세</h4>
				<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
			</div>	
<!-- 폼 테이블 -->			
			<table class="table-border mt5">
				<colgroup>
					<col width="100px">
					<col width="">
					<col width="100px">
					<col width="">
				</colgroup>
				<tbody>
					<tr>
						<th class="text-right">고객구분</th>
						<td>
							<div class="form-check form-check-inline">
								<input class="form-check-input" type="radio" name="own_yn" value="N" required="required" alt="고객구분" ${gpsInfo.own_yn eq 'N' ? 'checked="checked"' : ''}>
								<label class="form-check-label">고객</label>
							</div>
							<div class="form-check form-check-inline">
								<input class="form-check-input" type="radio" name="own_yn" value="Y" required="required" alt="고객구분" ${gpsInfo.own_yn eq 'Y' ? 'checked="checked"' : ''} >
								<label class="form-check-label">자사</label>
							</div>
						</td>
						<th class="text-right">종류</th>
						<td>
							<select class="form-control" id="gps_type_cd" name="gps_type_cd" required="required" alt="종류">
								<c:forEach items="${codeMap['GPS_TYPE']}" var="item">
									<c:if test="${item.show_yn eq 'Y' && item.use_yn eq 'Y'}">
										<option ${gpsInfo.gps_type_cd eq item.code_value ? 'selected="selected"' : ''} value="${item.code_value}">${item.code_name}</option>
									</c:if>
								</c:forEach>
							</select>
						</td>								
					</tr>
					<tr>
						<th class="text-right">개통번호</th>
						<td>
							<input type="text" class="form-control" value="${gpsInfo.gps_no}" id="gps_no" name="gps_no" required="required" alt="개통번호">
						</td>
						<th class="text-right">계약번호</th>
						<td>
							<input type="text" class="form-control" value="${gpsInfo.contract_no}" id="contract_no" name="contract_no" alt="계약번호">
						</td>							
					</tr>
					<tr>
						<th class="text-right">GPS모델</th>
						<td>
							<select class="form-control" id="gps_model_cd" name="gps_model_cd" required="required" alt="GPS모델">
								<c:forEach items="${codeMap['GPS_MODEL']}" var="item">
									<c:if test="${item.show_yn eq 'Y' && item.use_yn eq 'Y'}">
										<option ${gpsInfo.gps_model_cd eq item.code_value ? 'selected="selected"' : ''} value="${item.code_value}">${item.code_name}</option>
									</c:if>
								</c:forEach>
							</select>
						</td>	
						<th class="text-right">개통일</th>
						<td>
							<div class="input-group width120px">
								<input type="text" class="form-control border-right-0 calDate" id="open_dt" name="open_dt" dateFormat="yyyy-MM-dd" value="${gpsInfo.open_dt}" alt="개통일">
							</div>
						</td>							
					</tr>
					<tr>
						<th class="text-right">사용기간</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width60px">
									<input type="text" class="form-control" readonly value="${gpsInfo.use_time}">
								</div>
								<div class="col width22px">일</div>
							</div>
						</td>	
						<th class="text-right">관리센터</th>
						<td>
							<select class="form-control" id="center_org_code" name="center_org_code" alt="관리센터">
								<option value="">- 선택 -</option>
								<c:forEach items="${orgCenterList}" var="item">
									<option ${gpsInfo.center_org_code eq item.org_code ? 'selected="selected"' : ''} value="${item.org_code}">${item.org_name}</option>
								</c:forEach>
							</select>
						</td>					
					</tr>
					<tr>
						<th class="text-right">차대번호</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width180px">
									<div class="input-group">
										<input type="hidden" id="machine_seq" name="machine_seq" value="${gpsInfo.inst_yn eq 'Y' ? gpsInfo.machine_seq : ''}">
										<input type="text" class="form-control border-right-0" readonly id="body_no" name="body_no" alt="차대번호" value="${gpsInfo.inst_yn eq 'Y' ? gpsInfo.body_no : ''}">
										<button type="button" class="btn btn-icon btn-primary-gra" ${gpsInfo.inst_yn eq 'Y' ? 'disabled="disabled"' : ''} onclick="javascript:goSearchDeviceHisPanel();" ><i class="material-iconssearch"></i></button>
									</div>
								</div>
								<div class="col width40px">
									<c:if test="${gpsInfo.inst_yn eq 'Y'}">
										<button type="button" id="_goUnInst" class="btn btn-default" onclick="javascript:goUnInst();">탈거</button>
									</c:if>
								</div>
							</div>
						</td>	
						<th class="text-right">장비모델</th>
						<td>
							<div class="form-row inline-pd pr">
								<div class="col-auto">
									<input type="text" class="form-control" id="machine_name" name="machine_name" alt="장비모델" value="${gpsInfo.inst_yn eq 'Y' ? gpsInfo.machine_name : ''}" readonly="readonly">
								</div>
								<div class="col-auto">
									<button type="button" class="btn btn-primary-gra" onclick="javascript:openWorkDB();">업무DB</button>
								</div>
							</div>
						</td>						
					</tr>
					<tr>
						<th class="text-right">엔진번호</th>
						<td>
							<input type="text" class="form-control" readonly id="engine_no_1" name="engine_no_1" alt="엔진번호" value="${gpsInfo.inst_yn eq 'Y' ? gpsInfo.engine_no_1 : ''}">
						</td>	
						<th class="text-right">보유센터</th>
						<td>
							<select class="form-control"  disabled="disabled" id="machine_center_org_code" name="machine_center_org_code" readonly alt="보유센터">
								<option value=""></option>
								<c:forEach items="${orgCenterList}" var="item">
									<option ${gpsInfo.inst_yn eq 'Y' ? (gpsInfo.machine_center_org_code eq item.org_code ? 'selected="selected"' : '') : ''} value="${item.org_code}">${item.org_name}</option>
								</c:forEach>
							</select>
						</td>						
					</tr>								
				</tbody>
			</table>			
<!-- /폼 테이블 -->	
<!-- GPS수리내역 -->
			<div class="title-wrap mt10">
				<h4>GPS수리내역</h4>
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
				</div>
			</div>				
			<div  id="auiGrid" style="margin-top: 5px; height: 200px;"></div>
<!-- /GPS수리내역 -->
			<div class="btn-group mt10">
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