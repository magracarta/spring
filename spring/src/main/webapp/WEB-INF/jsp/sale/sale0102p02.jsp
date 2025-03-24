<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 계약관리 > 출하명세서-보유장비대비 > null > 보유장비
-- 작성자 : 손광진
-- 최초 작성일 : 2020-09-18 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		$(document).ready(function() {
			createAUIGrid();

			// 출하센터 - 출하담당이 아니면 저장버튼 숨김처리.
			<c:if test="${page.fnc.F00142_001 ne 'Y' && page.add.OUT_MNG_YN ne 'Y'}">
			$("#_goSave").hide();
			</c:if>
		});
		
		var posStatus = ${posList};
		console.log(posStatus);
		
		//엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "보유장비", "");
		}
		
		function goMachineDocList(rowIndex) {
			<c:if test="${page.fnc.F00142_001 ne 'Y' && page.add.OUT_MNG_YN ne 'Y'}">
			alert("장비 선지정 권한이 없습니다");
			return false;
			</c:if>
			var item = AUIGrid.getGridData(auiGrid)[rowIndex];

			// 장비기본입고 창고로 변경
			// if (item.machine_out_yn != "Y") {
			if (item.machine_in_yn != 'Y') {
				alert("출하센터 장비가 아닙니다.");
				return false;
			}

			// 장비순번관리에 등록되어있으면 순번관리에 등록된 품의서만 노출, 
			// 장비순번관리에 등록되어있지않으면 순번관리가 없는 품의서만 노출
			// var machineDocNo = item.turn_machine_doc_no;
			
			var popupOption = "";
			var params = {
				machine_name : item.machine_name, // 품의서 조회용
				// s_sale_turn_machine_doc_no : machineDocNo, // 계약출하순번
				s_machine_seq : item.machine_seq,
				s_body_no : item.body_no, // 컨펌창메세지에 차대번호
				s_machine_doc_no : "${inputParam.machine_doc_no}", // 쪽지에서 왔을 경우
				s_rowIndex : rowIndex,
				s_pre_yn : "Y", // 선지정을 위한 조회
				parent_js_name : "goSavePreMachineDoc"
			};
			$M.goNextPage('/sale/sale0102p04', $M.toGetParam(params), {popupStatus : popupOption});
		}
		
		// 상태변경, 특이사항 저장
		function goSave() {
			var items = AUIGrid.getEditedRowItems(auiGrid);
			
			if (items.length == 0) {
				alert("저장할 내용이 없습니다.");
				return false;
			}
			
			var frm = fnChangeGridDataToForm(auiGrid);
			
			$M.goNextPageAjaxSave(this_page+"/save", frm, {method : 'POST'},
					function(result) {
				    	if(result.success) {
				    		var equality = true;
				    		for (var i = 0; i < items.length; ++i) {
				    			if (items[i].machine_out_pos_status_cd != "${inputParam.machineOutPosCd}") {
				    				equality = false;
				    				break;
				    			}
				    		}
				    		
				    		if (opener != null && equality == false && confirm("본창을 새로고침하시겠습니까?") == true) {
				    			opener.location.reload();
				    		}
							AUIGrid.resetUpdatedItems(auiGrid);
						}
					}
				);
		}
		
		// 선지정 등록
		function goSavePreMachineDoc(data) {
			var item = data;
			var bodyNo = AUIGrid.getGridData(auiGrid)[item.rowIndex].body_no;
			item["body_no"] = bodyNo;
			$M.goNextPageAjax(this_page+"/preMachineDoc/save", $M.toGetParam(item), {method : 'POST'},
					function(result) {
				    	if(result.success) {
				    		AUIGrid.updateRow(auiGrid, { "pre_machine_doc_no" : item.machine_doc_no}, item.rowIndex);
							AUIGrid.resetUpdatedItems(auiGrid);
						} 
					}
				);
		}
		
		// 선지정 취소
		function goRemove(rowIndex) {
			if (confirm("지정출고를 삭제하시겠습니까?") == false) {
				return false;
			}
			
			var item = AUIGrid.getGridData(auiGrid)[rowIndex];
			
			var param = {
				machine_seq : item.machine_seq,
				machine_doc_no : item.pre_machine_doc_no,
				turn_remove_yn : "N"
			}
			
			/* // 순번삭제여부
			if (confirm("지정출고삭제 후,\n연결된 계약출하순번관리도 삭제하시겠습니까?") == true) {
				param.turn_remove_yn = "Y";
			} */
			
			$M.goNextPageAjax(this_page+"/preMachineDoc/remove", $M.toGetParam(param), {method : 'POST'},
					function(result) {
				    	if(result.success) {
				    		location.reload();
						}
					}
				);
		}
		
		// 품의서조회
		function goMachineDoc(rowIndex) {
			var item = AUIGrid.getGridData(auiGrid)[rowIndex];
			console.log(item);
			var param = {
				machine_doc_no : item.pre_machine_doc_no,
			}
			var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1300, height=750, left=0, top=0";
			$M.goNextPage('/sale/sale0101p01', $M.toGetParam(param), {popupStatus : poppupOption});
		}
		
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				height : 565,
				editable : true
			};
			var columnLayout = [
				{
					headerText : "모델", 
					dataField : "machine_name", 
					width : "100",
					minWidth : "90",
					style : "aui-center",
					editable : false
				},
				{ 
					headerText : "차대번호", 
					dataField : "body_no", 
					width : "160",
					minWidth : "90", 
					style : "aui-center aui-popup",
					editable : false
				},
				{ 
					headerText : "장비번호", 
					dataField : "machine_seq", 
					visible : false,
					style : "aui-center",
					editable : false
				},
				{ 
					headerText : "엔진번호", 
					dataField : "engine_no_1", 
					width : "100",
					minWidth : "90",
					style : "aui-center",
					editable : false
				},
				{ 
					headerText : "입고일", 
					dataField : "in_dt", 
					dataType : "date",  
					width : "70",
					minWidth : "50",
					style : "aui-center",
					formatString : "yy-mm-dd",
					editable : false
				},
				{ 
					headerText : "보유센터", 
					dataField : "in_org_name", 
					width : "60",
					minWidth : "30",
					style : "aui-center",
					editable : false
				},
				{ 
					headerText : "구분", 
					dataField : "machine_status_name", 
					width : "40",
					minWidth : "90",
					style : "aui-center",
					editable : false
				},
				<c:if test="${'1' ne inputParam.status_cd}">
				{ 
					headerText : "상태", 
					width : "90",
					minWidth : "20", 
					style : "aui-center",
					editable : false,
					dataField : "machine_out_pos_status_cd",
					renderer : {
						type : "DropDownListRenderer",
						keyField : "code_value", 
						valueField : "code_name", 	
						list : posStatus,
					},
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						for (var i = 0; i < posStatus.length; ++i) {
							if (value == posStatus[i].code_value) {
								return posStatus[i].code_name;
							}
						}
					    return value;
					},
				},
				</c:if>
				{ 
					headerText : "정비완료예정일", 
					dataField : "repair_finish_dt",
					dataType : "date",  
					width : "100",
					minWidth : "90",
					style : "aui-center aui-editable",
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
					},
					editable : true,
				},
				{ 
					headerText : "참고사항", 
					dataField : "remark", 
					width : "170",
					minWidth : "90",
					style : "aui-left",
					editable : true
				},
				{ 
					headerText : "출하일", 
					dataField : "out_dt", 
					dataType : "date",
					width : "100",
					minWidth : "90",
					style : "aui-center",
					formatString : "yy-mm-dd",
					editable : false
				},
				<c:if test="${'0' eq inputParam.status_cd}">
				{
					headerText : "지정여부",
					dataField : "pre_machine_doc_no",
					editable : false, // 그리드의 에디팅 사용 안함( 템플릿에서 만든 Select 로 에디팅 처리 하기 위함 )
					renderer : { // HTML 템플릿 렌더러 사용
						type : "TemplateRenderer",
					}, 
					width : "100",
					minWidth : "90",
					// dataField 로 정의된 필드 값이 HTML 이라면 labelFunction 으로 처리할 필요 없음.
					labelFunction : function (rowIndex, columnIndex, value, headerText, item ) { // HTML 템플릿 작성
						var template = "<div>";
						if (value == "") {
							template += '<span class="aui-grid-button-renderer aui-grid-button-percent-width" onclick="javascript:goMachineDocList('+rowIndex+')">품의서</span>';
						} else {
							template += '<span class="underline" onclick="javascript:goMachineDoc('+rowIndex+')">'+value.substring(4, 11)+'</span> <span><button class="btn btn-default btn-remove-dev" onclick="javascript:goRemove('+rowIndex+')"> X </button></span>';
						}
						template += '</div>';
						return template;
					}
				},
				</c:if>
				{
					// 계약출하순번지정여부
					dataField : "turn_machine_doc_no",
					visible : false
				},
				{
					// 출하센터여부
					dataField : "machine_out_yn",
					visible : false
				},
				{
					// 장비기본입고창고 여부
					dataField : "machine_in_yn",
					visible : false
				}
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, listJson);
			AUIGrid.bind(auiGrid, "cellClick", function(event){
				if(event.dataField == "body_no") {
					var popupOption = "";
					var params = {
						s_machine_seq : event.item.machine_seq,
					};
					// 장비대장상세 팝업 호출
					$M.goNextPage('/sale/sale0205p01', $M.toGetParam(params), {popupStatus : popupOption});					
				};
			});
			
			AUIGrid.bind(auiGrid, "cellEditBegin", function(event) {
				console.log("event : ", event);
				if (event.dataField == "repair_finish_dt") {
					if (event.item.machine_out_pos_status_cd != "2") {
						setTimeout(function() {
							   AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "상태가 정비후 일 경우에만 입력가능합니다.");
						}, 1);
						return false;
					}
				}
			});	
			
			AUIGrid.bind(auiGrid, "cellEditEnd", function(event) {
				if (event.dataField == "machine_out_pos_status_cd") {
					if (event.value != "2") {
						AUIGrid.updateRow(auiGrid, { "repair_finish_dt" : "" }, event.rowIndex);
					}
				}
			});	
			
			$("#auiGrid").resize();
		}
		
		// 팝업 닫기
		function fnClose() {
			window.close();
		}
		
	</script>
</head>
<body class="bg-white class">
<form id="main_form" name="main_form">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
            <button type="button" class="btn btn-icon"></button>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
<!-- 폼테이블 -->					
			<div>
				<div class="title-wrap">
					<h4>보유장비목록</h4>
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
					</div>
				</div>
			</div>
			<div id="auiGrid" style="margin-top: 5px; height: 350px;"></div>				
<!-- /폼테이블 -->	
<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5">	
				<div class="left">
					총 <strong class="text-primary">${total_cnt}</strong>건
				</div>						
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
        </div>
    </div>
<!-- /팝업 -->

</form>
</body>
</html>