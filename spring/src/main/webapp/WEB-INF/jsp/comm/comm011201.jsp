<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 기준정보 > 문자템플릿관리 > 신규등록 > null
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-03-12 18:27:05
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		var auiGrid; // 장비
		var centerJson = ${orgCenterListJson}
		var makerJson = ${makerJson}
		var auiGrids = [{auiGrid:{}, value:"centerGrid", list:centerJson.map(function(center) {return {code: center.org_code,code_name: center.org_name}})}, // 센터
						{auiGrid:{}, value:"makerGrid", list:makerJson}]  // 메이커
						
		$(document).ready(function() {
			for (var i = 0; i < auiGrids.length; ++i) {
				createGrid(i); // 센터 메이커 그리드
			}
			createMachineGrid();
		});
		
		window.onresize = function() {
			for (var i = 0; i < auiGrids.length; ++i) {
				fnResizeGrid(i);
			}
		};
		
		function fnResizeGrid(i) {
			setTimeout(function() {
				AUIGrid.resize(auiGrids[i].auiGrid);
				AUIGrid.resize(auiGrid);
			}, 1);
		}
		
		function goSave() {
			if($M.validation(document.main_form) == false) {
				return;
			};
			var centerTemp = AUIGrid.getCheckedRowItemsAll("centerGrid");
			var centerArr = [];
			for (var i = 0; i < centerTemp.length; ++i) {
				centerArr.push(centerTemp[i].code);
			}
			
			var makerTemp = AUIGrid.getCheckedRowItemsAll("makerGrid");
			var makerArr = [];
			for (var i = 0; i < makerTemp.length; ++i) {
				makerArr.push(makerTemp[i].code);
			}
			
			var machineTemp = AUIGrid.getGridData(auiGrid);
			var machineArr = [];
			for (var i = 0; i < machineTemp.length; ++i) {
				machineArr.push(machineTemp[i].machine_plant_seq);
			}
			
			var param = {
					template_name : $M.getValue("template_name"),
					sms_template_type_cd : $M.getValue("sms_template_type_cd"),
					template_text : encodeURIComponent($M.getValue("template_text")),
					sort_no : $M.getValue("sort_no"),
					cap_yn : $M.getValue("cap_yn"),
					use_yn : $M.getValue("use_yn"),
					center_org_code_str : $M.getArrStr(centerArr),
					maker_cd_str : $M.getArrStr(makerArr),
					machine_plant_seq_str : $M.getArrStr(machineArr) 
			}
			$M.goNextPageAjaxSave("/comm/comm0112", $M.toGetParam(param), {method : 'POST'},
				function(result) {
		    		if(result.success) {
		    			alert("정상 처리되었습니다.");
		    			fnList();
					}
				}
			);
		}
		
		function createGrid(i) {
			// 그리드 속성 설정
			var gridPros = {
				rowIdField : "code",
				//체크박스 출력 여부
				showRowCheckColumn: true,
				//전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
				showStateColumn : true,
				editable : false,
			};
			var headerText = i == 0 ? "센터명" : "메이커";
			var columnLayout = [
				{
					dataField : "code",
					visible : false
				},
				{
					dataField : "code_name",
					headerText : headerText,
				}
			];
			auiGrids[i].auiGrid = AUIGrid.create(auiGrids[i].value, columnLayout, gridPros);
			AUIGrid.setGridData(auiGrids[i].auiGrid, auiGrids[i].list);
			AUIGrid.bind(auiGrids[i].auiGrid, "rowCheckClick", function( event ) {
			      var item = event.item;
			      var rowIndex = event.rowIndex;
			      var checked = event.checked;
			      console.log(checked);
			      var total = AUIGrid.getCheckedRowItemsAll(auiGrids[i].value).length;
				  $("#"+auiGrids[i].value+"_total_cnt").html(total);
			});
			AUIGrid.bind(auiGrids[i].auiGrid, "rowAllCheckClick", function( checked ) {
				var total = AUIGrid.getCheckedRowItemsAll(auiGrids[i].value).length;
				$("#"+auiGrids[i].value+"_total_cnt").html(total);
			});
		}
		
		function createMachineGrid() {
			// 그리드 속성 설정
			var gridPros = {
				rowIdField : "_$uid",
				showStateColumn : true,
				editable : false,
			};
			var columnLayout = [
				{
					dataField : "machine_plant_seq",
					visible : false
				},
				{
					dataField : "machine_name",
					headerText : "모델명",
				},
				{
					width : "20%",
					headerText : "삭제",
					dataField : "removeBtn",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							var isRemoved = AUIGrid.isRemovedById(auiGrid, event.item._$uid);
							if (isRemoved == false) {
								AUIGrid.removeRow(event.pid, event.rowIndex);								
							} else {
								AUIGrid.restoreSoftRows(auiGrid, "selectedIndex"); 
							};
							var total = AUIGrid.getGridData(auiGrid).length;
							$("#machineGrid_total_cnt").html(total);
						},
					},
					labelFunction : function(rowIndex, columnIndex, value,
							headerText, item) {
						return '삭제'
					},
					style : "aui-center",
					editable : false
				}
			];
			auiGrid = AUIGrid.create("auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData("auiGrid", []);
			AUIGrid.bind(auiGrid, "rowCheckClick", function( event ) {
			      var item = event.item;
			      var rowIndex = event.rowIndex;
			      var checked = event.checked;
			      console.log(checked);
			      var total = AUIGrid.getCheckedRowItemsAll(auiGrid).length;
				  $("#machineGrid_total_cnt").html(total);
			});
		}
		
		function fnSetModelResult(obj) {
			if (Array.isArray(obj) == true) {
				for (var i = 0; i < obj.length; ++i) {
					var isUnique = AUIGrid.isUniqueValue(auiGrid, "machine_plant_seq", obj[i].machine_plant_seq);
					if (isUnique == false) {
						alert("이미 등록된 모델이 있습니다.");
						return false;
					}
					var item = new Object();
					item.machine_name = obj[i].machine_name;
					item.machine_plant_seq = obj[i].machine_plant_seq;
					AUIGrid.addRow(auiGrid, item, 'last');
				}
			} else {
				var item = new Object();
				item.machine_name = obj.machine_name;
				item.machine_plant_seq = obj[i].machine_plant_seq;
				AUIGrid.addRow(auiGrid, item, 'last');
			}
			var total = AUIGrid.getGridData(auiGrid).length;
			$("#machineGrid_total_cnt").html(total);
		}
	
		function fnList() {
			// history.back();
			$M.goNextPage("/comm/comm0112");
		}
		
		function fnAddConst() {
			console.log($M.getValue("cons"));
			if ($M.getValue("cons") == "") {
				alert("상수를 선택하세요.");
			} else {
				fnTypeInTextarea($("#template_text"), $M.getValue("cons"));				
			}
		}
		
		function fnTypeInTextarea(el, newText) {
			  var start = el.prop("selectionStart");
			  var end = el.prop("selectionEnd");
			  var text = el.val();
			  var before = text.substring(0, start);
			  var after  = text.substring(end, text.length);
			  el.val(before + newText + after);
			  el[0].selectionStart = el[0].selectionEnd = start + newText.length;
			  el.focus();
			  return false;
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
						<button type="button" class="btn btn-outline-light" onclick="javascript:fnList()"><i class="material-iconskeyboard_backspace text-default"></i></button>
						<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
					</div>
				</div>
<!-- /상세페이지 타이틀 -->
				<div class="contents">
<!-- 폼테이블 -->					
					<div>
						<table class="table-border">
							<colgroup>
								<col width="100px">
								<col width="">
								<col width="100px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th class="text-right essential-item">제목</th>
									<td>
										<input type="text" class="form-control essential-bg" id="template_name" name="template_name" style="width:200px;" datatype="string" maxlength="100" alt="제목" required="required">
									</td>		
									<th rowspan="2" class="text-right essential-item">적용범위</th>
									<td rowspan="2">
										<c:forEach var="item" items="${codeMap.SMS_TEMPLATE_TYPE}" varStatus="status">
											<div class="form-check form-check-inline">
												<input class="form-check-input" type="radio" name="sms_template_type_cd" value="${item.code_value}" ${status.first?'checked':''}>
												<label class="form-check-label">${item.code_name}</label>
											</div>
										</c:forEach>
									</td>						
								</tr>
								<tr>
									<th class="text-right essential-item">CAP여부</th>
									<td>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" name="cap_yn" value="Y">
											<label class="form-check-label">적용</label>
										</div>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" name="cap_yn" value="N" checked="checked">
											<label class="form-check-label">미적용</label>
										</div>
									</td>	
								</tr>
							</tbody>
						</table>
					</div>					
<!-- /폼테이블 -->	
					<div class="row mt10">
						<div class="col-3">
<!-- 상수삽입 -->
							<div class="title-wrap">
								<div class="smstable-search">
									<h5>상수삽입</h5>
									<select class="form-control mr5" id="cons" name="cons">
										<option value="">- 선택 -</option>
										<c:forEach var="item" items="${codeMap.SMS_TEMPLATE_CONST}">
											<option value="$${item.code_value}$">${item.code_name}</option>
										</c:forEach>
									</select>
									<button type="button" class="btn btn-dark" onclick="javascript:fnAddConst()">적용</button>
								</div>									
							</div>
							<textarea class="text-insert essential-bg" style="height: 500px; resize: none;" id="template_text" name="template_text" required="required" alt="내용" maxlength="2000"></textarea>
<!-- /상수삽입 -->
						</div>
						<div class="col-3">
<!-- 사용센터 -->
							<div class="title-wrap">
								<h4>사용센터</h4>
							</div>
							<div class="smstable-section">
								<div id="centerGrid" style="margin-top: 5px; height: 454px;"></div>
								<div class="btn-group mt5">	
									<div class="left">
										총 <strong class="text-primary" id="centerGrid_total_cnt">0</strong>건
									</div>
								</div>
							</div>											
							
<!-- /사용센터 -->												
						</div>
						<div class="col-3">
<!-- 메이커 -->
							<div class="title-wrap">
								<h4>메이커</h4>
							</div>
							<div class="smstable-section">
								<div id="makerGrid" style="margin-top: 5px; height: 454px;"></div>
								<div class="btn-group mt5">	
									<div class="left">
										총 <strong class="text-primary" id="makerGrid_total_cnt">0</strong>건
									</div>
								</div>
							</div>											
							
<!-- /메이커 -->
						</div>
						<div class="col-3">
<!-- 모델 -->
							<div class="title-wrap">
								<h4>모델</h4>
							</div>
							<div class="smstable-section">
								<div class="smstable-search" style="height: 24px !important">
									<button type="button" class="btn btn-dark" onclick="javascript:openSearchModelPanel('fnSetModelResult', 'Y')">추가</button>
								</div>
								<div id="auiGrid" style="margin-top: 5px; height: 430px;"></div>
								<div class="btn-group mt5">	
									<div class="left">
										총 <strong class="text-primary" id="machineGrid_total_cnt">0</strong>건
									</div>
								</div>
							</div>	
<!-- /모델 -->
						</div>
					</div>


					<div class="btn-group mt10">
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>
					</div>
				</div>						
			</div>		
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>	
		</div>
<!-- /contents 전체 영역 -->	
</div>
<input type="hidden" id="use_yn" name="use_yn" value="Y">
<input type="hidden" id="sort_no" name="sort_no" value="0">
</form>	
</body>
</html>