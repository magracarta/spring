<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 기준정보 > 문자템플릿관리 > null > 문자템플릿상세
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
		
		function goModify() {
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
			var machineDelTemp = AUIGrid.getRemovedItems(auiGrid);
			var machineDelArr = [];
			for (var i = 0; i < machineDelTemp.length; ++i) {
				machineDelArr.push(machineDelTemp[i].machine_plant_seq);
			}
			var machineArr = [];
			for (var i = 0; i < machineTemp.length; ++i) {
				if (!(machineDelArr.indexOf(machineTemp[i].machine_plant_seq) > -1)) {
					machineArr.push(machineTemp[i].machine_plant_seq);
				}
			}
			var param = {
					sms_template_seq : ${inputParam.sms_template_seq},
					template_name : $M.getValue("template_name"),
					sms_template_type_cd : $M.getValue("sms_template_type_cd"),
					template_text : encodeURIComponent($M.getValue("template_text")),
					sort_no : $M.getValue("sort_no"),
					cap_yn : $M.getValue("cap_yn"),
					mch_type_cad : $M.getValue("mch_type_cad"),
					use_yn : $M.getValue("use_yn"),
					center_org_code_str : $M.getArrStr(centerArr),
					maker_cd_str : $M.getArrStr(makerArr),
					machine_plant_seq_str : $M.getArrStr(machineArr) 
			};
			console.log(param);
			$M.goNextPageAjaxModify("/comm/comm0112", $M.toGetParam(param), {method : 'POST'},
				function(result) {
		    		if(result.success) {
		    			alert("정상 처리되었습니다.");
		    			AUIGrid.removeSoftRows(auiGrid);
						AUIGrid.resetUpdatedItems(auiGrid);
						var total = AUIGrid.getGridData(auiGrid).length;
						$("#machineGrid_total_cnt").html(total);
					}
				}
			);
		}
		
		function goRemove() {
			$M.goNextPageAjaxRemove("/comm/comm0112/"+${inputParam.sms_template_seq}+"/remove", '', {method : 'POST'},
				function(result) {
		    		if(result.success) {
		    			alert("정상 처리되었습니다.");
		    			fnClose();
		    			if (opener != null && opener.goSearch) {
		    				opener.goSearch();
		    			}
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
			var list;
			if (i == 0) {
				list = ${detail.center}
				console.log(list);
			} else {
				list = ${detail.maker}
				console.log(list);
			}
			var tempArr = [];
			for (var j = 0; j < list.length; ++j) {
				if (i == 0) {
					tempArr.push(list[j].org_code);					
				} else {
					tempArr.push(list[j].maker_cd);
				}
			}
			$("#"+auiGrids[i].value+"_total_cnt").html(tempArr.length);
			console.log(tempArr);
			AUIGrid.addCheckedRowsByValue(auiGrids[i].value, "code", tempArr);
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
					dataField : "machine_name",
					headerText : "모델명",
				},
				{
					dataField : "machine_plant_seq",
					visible : false
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
			AUIGrid.setGridData("auiGrid", ${detail.machine});
			var total = AUIGrid.getGridData(auiGrid).length;
			$("#machineGrid_total_cnt").html(total);
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
	
		function fnClose() {
			window.close();
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
<body class="bg-white">
<form id="main_form" name="main_form">
<div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
<!-- 폼테이블 -->					
			<div>
			<table class="table-border">
				<colgroup>
					<col width="100px">
					<col width="">
					<col width="100px">
					<col width="">
					<col width="100px">
					<col width="">
					<col width="100px">
					<col width="">
				</colgroup>
				<tbody>
					<tr>
						<th class="text-right essential-item">제목</th>
						<td colspan="3">
							<input type="text" class="form-control essential-bg" id="template_name" name="template_name" style="width:200px;" datatype="string" maxlength="100" alt="제목" required="required" value="${detail.master.template_name}">
						</td>		
						<th rowspan="2" class="text-right essential-item">적용범위</th>
						<td rowspan="2" colspan="3">
							<c:forEach var="item" items="${codeMap.SMS_TEMPLATE_TYPE}">
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" id="${item.code_value}" name="sms_template_type_cd" value="${item.code_value}"
									${detail.master.sms_template_type_cd==item.code_value?'checked':''}>
									<label class="form-check-label" for="${item.code_value }">${item.code_name}</label>
								</div>
							</c:forEach>
						</td>						
					</tr>
					<tr>
						<th class="text-right essential-item">CAP여부</th>
						<td>
							<div class="form-check form-check-inline">
								<input class="form-check-input" type="radio" value="Y" id="cap_yn_y" name="cap_yn"
								${detail.master.cap_yn=='Y'?'checked':''}>
								<label class="form-check-label" for="cap_yn_y">적용</label>
							</div>
							<div class="form-check form-check-inline">
								<input class="form-check-input" type="radio" value="N" id="cap_yn_n" name="cap_yn"
								${detail.master.cap_yn=='N'?'checked':''}>
								<label class="form-check-label" for="cap_yn_n">미적용</label>
							</div>
						</td>
						<th class="text-right essential-item">장비계약</th>
						<td>
							<div class="form-check form-check-inline">
								<input class="form-check-input" type="radio" value="C" id="mch_type_cad_c" name="mch_type_cad"
								${detail.master.mch_type_cad == 'C' ? 'checked' : ''}>
								<label class="form-check-label" for="mch_type_cad_c">건기</label>
							</div>
							<div class="form-check form-check-inline">
								<input class="form-check-input" type="radio" value="A" id="mch_type_cad_a" name="mch_type_cad"
								${detail.master.mch_type_cad == 'A' ? 'checked' : ''}>
								<label class="form-check-label" for="mch_type_cad_a">농기</label>
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
				<textarea class="text-insert essential-bg" style="height: 500px; resize: none;" id="template_text" name="template_text" required="required" alt="내용" maxlength="2000">${detail.master.template_text}</textarea>
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
<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5">						
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
        </div>
    </div>
<input type="hidden" id="use_yn" name="use_yn" value="${detail.master.use_yn}">
<input type="hidden" id="sort_no" name="sort_no" value="${detail.master.sort_no}">
</form>
</body>
</html>