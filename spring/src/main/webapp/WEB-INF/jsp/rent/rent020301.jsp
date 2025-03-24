<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈 > 렌탈대장 > GPS관리 > GPS 신규등록 > null
-- 작성자 : 김상덕
-- 최초 작성일 : 2020-05-21 20:04:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGrid();
		});
		
		// 정비작업 그리드
		function createAUIGrid() {
			var gridPros = {
				editable : true,	
				// rowIdField 설정
				rowIdField : "_$uid", 
				// rowIdField가 unique 임을 보장
// 				showRowNumColumn : true,
				enableSorting : true,
				showStateColumn : true
			};
			
			var columnLayout = [
				{
					headerText : "일자",
					dataField : "repair_dt",
					dataType : "date",   
					width : "15%",
					style : "aui-center aui-editable",
					required : true,
					editable : true,				
					dataInputString : "yyyymmdd",
					formatString : "yyyy-mm-dd",
					editRenderer : {
						type : "JQCalendarRenderer", // datepicker 달력 렌더러 사용
						defaultFormat : "yyyymmdd", // 원래 데이터 날짜 포맷과 일치 시키세요. (기본값: "yyyy/mm/dd")
						onlyCalendar : false, // 사용자 입력 불가, 즉 달력으로만 날짜입력 ( 기본값: true )
						maxlength : 8,
						onlyNumeric : true, // 숫자만
						validator : function(oldValue, newValue, rowItem) { // 에디팅 유효성 검사
							return fnCheckDate(oldValue, newValue, rowItem);
						},
						showEditorBtnOver : true
					}
				},
				{
					headerText : "내역", 
					dataField : "repair_desc", 
					width : "30%", 
					style : "aui-left aui-editable",
				},
				{ 
					headerText : "비용", 
					dataField : "repair_amt", 
					width : "15%", 
					style : "aui-right aui-editable",			
					dataType : "numeric",					
					formatString : "#,##0",
					editRenderer : {
				    	type : "InputEditRenderer",
					    onlyNumeric : true,
				      	auiGrid : "#auiGrid",
			     	 	maxlength : 20
				      	// 에디팅 유효성 검사
				      	//validator : AUIGrid.commonValidator
					}	
				},
				{ 
					headerText : "비고", 
					dataField : "repair_remark", 
					width : "30%", 
					style : "aui-left aui-editable",
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
					dataField : "use_yn", 
					visible : false
				},
				{ 
					dataField : "seq_no", 
					visible : false
				}			
			];
			// 실제로 #grid_wrap에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, []);
		}
		
		// 그리드 빈값 체크
		function isValid() {
			var msg = "반드시 값을 입력해야 합니다.";
			// 기본 필수 체크
			var reqField = ["repair_dt"];
			return AUIGrid.validateGridData(auiGrid, reqField, msg);
		}
		
		// 행추가
	    function fnAdd() {
	    	if(isValid()) {
				var row = new Object();
				row.seq_no = '0';
				row.repair_dt = '';
				row.repair_desc = '';
	 			row.repair_amt = '';
	 			row.repair_remark = '';
	 			row.use_yn = 'Y';
				AUIGrid.addRow(auiGrid, row, "last");
			}
	    }
		
	    function goSave() {
	    	if($M.validation(document.main_form) == false) {
				return false;
			};
			if(!isValid()) {
				return false;
			}
			// GPS수리내역
			var repairTemp = AUIGrid.getGridData(auiGrid);
			var repairSeqNoArr = [];
			var repairDtArr = [];
			var repairDescArr = [];
			var repairAmtArr = [];
			var repairRemarkArr = [];
			var repairUseYnArr = [];
			for (var i in repairTemp) {
				repairSeqNoArr.push(repairTemp[i].seq_no);
				repairDtArr.push(repairTemp[i].repair_dt);
				repairDescArr.push(repairTemp[i].repair_desc || "");
				repairAmtArr.push(repairTemp[i].repair_amt || "");
				repairRemarkArr.push(repairTemp[i].repair_remark || "");
				repairUseYnArr.push(repairTemp[i].use_yn);
			}
			
			var param = {
				"own_yn" : $M.getValue("own_yn")
				, "gps_type_cd" : $M.getValue("gps_type_cd")
				, "gps_no" : $M.getValue("gps_no")
				, "contract_no" : $M.getValue("contract_no")
				, "gps_model_cd" : $M.getValue("gps_model_cd")
				, "open_dt" : $M.getValue("open_dt")
				, "center_org_code" : $M.getValue("center_org_code")
				, "machine_seq" : $M.getValue("machine_seq")
				, "seq_no_str" : $M.getArrStr(repairSeqNoArr)
				, "repair_dt_str" : $M.getArrStr(repairDtArr)
				, "repair_desc_str" : $M.getArrStr(repairDescArr, {isEmpty : true})
				, "repair_amt_str" : $M.getArrStr(repairAmtArr, {isEmpty : true})
				, "repair_remark_str" : $M.getArrStr(repairRemarkArr, {isEmpty : true})
				, "repair_use_yn_str" : $M.getArrStr(repairUseYnArr)
			};
			
			$M.goNextPageAjaxSave("/rent/rent0203" + "/save", $M.toGetParam(param), {method : 'POST'},
				function(result) {
					if(result.success) {
						alert("저장이 완료되었습니다.");
						fnList();
					}
				}
			);
	    }
	
	    function fnList() {
	    	history.back();
	    }

		// 장비대장 팝업 호출
		function goSearchDeviceHisPanel() {
			var param = {
				isSearchFromGps : "Y"
			}
			openSearchDeviceHisPanel('fnSetMachineInfo', $M.toGetParam(param));
		}
	    
	    // 장비대장관리 팝업에서 선택한 결과 세팅
	    function fnSetMachineInfo(data) {
	    	$M.setValue("machine_seq", data.machine_seq);
	    	$M.setValue("body_no", data.body_no);
	    	$M.setValue("machine_name", data.machine_name);
	    	$M.setValue("engine_no_1", data.engine_no_1);
	    	$M.setValue("machine_center_org_code", data.center_org_code);
	    }
	
	 	// 업무DB 연결 함수 21-08-05이강원
     	function openWorkDB(){
     		openWorkDBPanel($M.getValue("machine_seq"));
     	}
	
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<div class="layout-box">
<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
<!-- 상세페이지 타이틀 -->
				<div class="main-title detail">
					<div class="detail-left">
						<button type="button" onclick="javascript:fnList();" class="btn btn-outline-light"><i class="material-iconskeyboard_backspace text-default"></i></button>
						<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
					</div>
				</div>
<!-- /상세페이지 타이틀 -->
				<div class="contents" style="width : 60%;">
<!-- 폼 테이블 -->			
					<table class="table-border">
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
										<input class="form-check-input" type="radio" name="own_yn" value="N" required="required" alt="고객구분">
										<label class="form-check-label">고객</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" name="own_yn" value="Y" required="required" alt="고객구분" checked="checked">
										<label class="form-check-label">자사</label>
									</div>
								</td>
								<th class="text-right">종류</th>
								<td>
									<select class="form-control" id="gps_type_cd" name="gps_type_cd" required="required" alt="종류">
										<c:forEach items="${codeMap['GPS_TYPE']}" var="item">
											<c:if test="${item.show_yn eq 'Y' && item.use_yn eq 'Y'}">
												<option value="${item.code_value}">${item.code_name}</option>
											</c:if>
										</c:forEach>
									</select>
								</td>								
							</tr>
							<tr>
								<th class="text-right">개통번호</th>
								<td>
									<input type="text" class="form-control" id="gps_no" name="gps_no" required="required" alt="개통번호">
								</td>
								<th class="text-right">계약번호</th>
								<td>
									<input type="text" class="form-control" id="contract_no" name="contract_no" alt="계약번호">
								</td>							
							</tr>
							<tr>
								<th class="text-right">GPS모델</th>
								<td>
									<select class="form-control" id="gps_model_cd" name="gps_model_cd" required="required" alt="GPS모델">
										<c:forEach items="${codeMap['GPS_MODEL']}" var="item">
											<c:if test="${item.show_yn eq 'Y' && item.use_yn eq 'Y'}">
												<option value="${item.code_value}">${item.code_name}</option>
											</c:if>
										</c:forEach>
									</select>
								</td>	
								<th class="text-right">개통일</th>
								<td>
									<div class="input-group width120px" >
										<input type="text" class="form-control border-right-0 calDate" id="open_dt" name="open_dt" alt="개통일" dateFormat="yyyy-MM-dd" value="${inputParam.s_current_dt}">
									</div>
								</td>							
							</tr>
							<tr>
								<th class="text-right">사용기간</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width60px">
											<input type="text" class="form-control" readonly>
										</div>
										<div class="col width22px">일</div>
									</div>
								</td>	
								<th class="text-right">관리센터</th>
								<td>
									<select class="form-control" id="center_org_code" name="center_org_code" alt="관리센터">
										<option value="">- 선택 -</option>
										<c:forEach items="${orgCenterList}" var="item">
											<option value="${item.org_code}">${item.org_name}</option>
										</c:forEach>
									</select>
								</td>					
							</tr>
							<tr>
								<th class="text-right">차대번호</th>
								<td>
									<div class="input-group">
										<input type="hidden" id="machine_seq" name="machine_seq">
										<input type="text" class="form-control border-right-0" readonly id="body_no" name="body_no" alt="차대번호">
										<button type="button" onclick="javascript:goSearchDeviceHisPanel();" class="btn btn-icon btn-primary-gra"><i class="material-iconssearch"></i></button>
									</div>
								</td>	
								<th class="text-right">장비모델</th>
								<td>
									<div class="form-row inline-pd pr">
										<div class="col-auto">
											<input type="text" class="form-control" readonly id="machine_name" name="machine_name" alt="장비모델">
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
									<input type="text" class="form-control" readonly id="engine_no_1" name="engine_no_1" alt="엔진번호">
								</td>	
								<th class="text-right">보유센터</th>
								<td>
									<select class="form-control"  disabled="disabled" id="machine_center_org_code" name="machine_center_org_code" readonly alt="보유센터">
										<option value=""></option>
										<c:forEach items="${orgCenterList}" var="item">
											<option value="${item.org_code}">${item.org_name}</option>
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
					<div id="auiGrid" style="margin-top: 5px; height: 200px;"></div>
<!-- /GPS수리내역 -->
					<div class="btn-group mt10">
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>
					</div>
				</div>						
			</div>		
		</div>
<!-- /contents 전체 영역 -->	
</div>
</form>	
</body>
</html>