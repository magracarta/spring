<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 계약관리 > 계약/출하 > null > 출하예정시간
-- 작성자 : 김태훈
-- 최초 작성일 : 2021-04-09 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	<%-- 여기에 스크립트 넣어주세요. --%>
		var auiGrid;
		var allChecked = false;
		var list;
		var reasonList = ["출고불가설정", "신차출고준비"];
		
		$(document).ready(function() {
			createAUIGrid();
		});
		
		function fnClose() {
			window.close();
		}	
		
		var myEditRenderer = {
			type : "DropDownListRenderer",
			showEditorBtnOver : true, // 마우스 오버 시 에디터버턴 보이기
			list : reasonList
		};
		
		var myEditRenderer2 = {
			editable : false
		};
		
		// 출고불가
		function goSave() {
			var item = [];
			var remark = [];
			var itemArr = AUIGrid.getCheckedRowItemsAll(auiGrid); // 체크된 그리드 데이터
			for (var i = 0; i < itemArr.length; i++) {
				item.push(itemArr[i].code);
				remark.push(itemArr[i].disabled_yn);
			};
			if (!confirm("저장하시겠습니까?")) {
				return false;
			}
			var param = {
				out_org_code : "${inputParam.s_out_org_code}",
				receive_plan_dt : "${inputParam.s_receive_plan_dt}",
				receive_plan_ti_str : $M.getArrStr(item),
				remark_str : $M.getArrStr(remark)
			}
			$M.goNextPageAjax(this_page, $M.toGetParam(param), {method : 'POST'},
				function(result) {
			    	if(result.success) {
			    		if (opener != null) {
			    			opener.${inputParam.parent_js_name}();
			    		}
						window.close();
					}
				}
			);
		}
		
		// 셀 클릭으로 엑스트라 체크박스 체크/해제 하기
		function cellClickHandler(event) {
			// 출하캘린더가 아니면
			<c:if test="${inputParam.parent_js_name ne 'fnRefresh'}">
		    	if (event.item.disabled_yn != "") {
		    		AUIGrid.showToastMessage(auiGrid, event.rowIndex, 2, "선택할 수 없는 시간입니다.");
		    		return false;
		        } else {
		        	try{
		        		opener.${inputParam.parent_js_name}(event.item);
						window.close();
					} catch(e) {
						alert('호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현하세요.');
					}
		        }
	    	</c:if>
		};
		
		function createAUIGrid() {
			//그리드 생성 _ 지급품목
			var gridPros_product = {
				rowIdField : "code",
	        	rowStyleFunction : function(rowIndex, item) {
					if (item.disabled_yn == "출고") {
						return "aui-status-complete";
					}
					if (item.disabled_yn != "" && item.reg_mem_name != "${SecureUser.kor_name}") {
						return "aui-status-complete";
					}
				},
				<c:if test="${inputParam.parent_js_name eq 'fnRefresh'}">
					//체크박스 출력 여부
					showRowCheckColumn : true,
					editable : true,
					//전체선택 체크박스 표시 여부
					showRowAllCheckBox : true,
					// 전체 선택 체크박스가 독립적인 역할을 할지 여부
					independentAllCheckBox : true,
					
					// 엑스트라 체크박스 체커블 함수
					// 이 함수는 사용자가 체크박스를 클릭 할 때 1번 호출됩니다.
					rowCheckableFunction : function(rowIndex, isChecked, item) {
						if(item.disabled_yn == "출고") {
							return false;
						} else if (item.reg_mem_no != "${SecureUser.mem_no}" && item.reg_mem_no != "") {
							return false;
						}
						return true;
					},
					rowCheckDisabledFunction : function(rowIndex, isChecked, item) {
						if(item.disabled_yn == "출고") { // 이름이 Anna 인 경우 사용자 체크 못하게 함.
							return false; // false 반환하면 disabled 처리됨
						} else if (item.reg_mem_no != "${SecureUser.mem_no}" && item.reg_mem_no != "") {
							return false;
						} 
						return true;
					},
				</c:if>
			};
			var columnLayout_product = [
				{
					headerText : "시간",
					dataField : "code_name",
					editable : false,
					width : "50",
				},
				{
					headerText : "-",
					dataField : "code_v1",
					editable : false,
					width : "50",
					labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) { 
						var retStr = value;
						if (retStr == "A") {
							retStr = "오전";
						} else {
							retStr = "오후";
						}	
						return retStr;
					},
				},
				{
					headerText : "사유",
					dataField : "disabled_yn",
					editRenderer : {
						type : "DropDownListRenderer",
						showEditorBtnOver : true, // 마우스 오버 시 에디터버턴 보이기
						list : reasonList
					},
				},
				{
					headerText : "등록자",
					width : "80",
					editable : false,
					dataField : "reg_mem_name",
					visible : "${inputParam.s_doc_mem_yn}" == "Y" ? false : true
				},
				{
					dataField : "code",
					visible : false
				},
				{
					dataField : "reg_mem_no",
					visible : false
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout_product, gridPros_product);
			list = ${list}
			console.log(list);
			AUIGrid.setGridData(auiGrid, list);
			$("#auiGrid_part").resize();
			
			AUIGrid.bind(auiGrid, "cellClick", cellClickHandler);
			
			// 에디팅 시작 이벤트 바인딩
			AUIGrid.bind(auiGrid, "cellEditBegin", function(event) {
				// rowIdField 설정 값 얻기
				if(event.dataField == "disabled_yn") {
					var checked = AUIGrid.isCheckedRowById(auiGrid, event.item.code);
					if (!checked) {
						if (event.item.disabled_yn != "출고") {
							setTimeout(function(){ AUIGrid.showToastMessage(auiGrid, event.rowIndex, 2, "체크 후 지정하세요.")}, 1);
						}
						return false;
					} else {
						return true; // 다른 필드들은 편집 허용
					}
				}
			});
			
			// 체크박스 클린 이벤트 바인딩
			AUIGrid.bind(auiGrid, "rowCheckClick", function( event ) {
				if (event.checked) {
					var yArr = [];
					for (var i = 0; i < list.length; ++i) {
						if (list[i].disabled_yn != "출고" && (list[i].reg_mem_no == "${SecureUser.mem_no}" || list[i].reg_mem_no == "")) {
							yArr.push(list[i].code);
						}
					}
					var item = [];
					var itemArr = AUIGrid.getCheckedRowItemsAll(auiGrid); // 체크된 그리드 데이터
					for (var i = 0; i < itemArr.length; i++) {
						item.push(itemArr[i].code);
					};
					if (yArr.length != item.length) {
						allChecked = false;
						AUIGrid.setAllCheckedRows(auiGrid, allChecked);
					} else {
						allChecked = true;
						AUIGrid.setAllCheckedRows(auiGrid, allChecked);
					}
					AUIGrid.updateRowsById(auiGrid, {disabled_yn : reasonList[0], code : event.item.code, reg_mem_name : "${SecureUser.kor_name}"});
					
				} else {
					allChecked = false;
					AUIGrid.setAllCheckedRows(auiGrid, allChecked);
					AUIGrid.updateRowsById(auiGrid, {disabled_yn : "", code : event.item.code, reg_mem_name : ""});
							
				}
			});
			
			var arr = [];
			var yArr = [];
			console.log(list);
			for (var i = 0; i < list.length; ++i) {
				if (list[i].disabled_yn != "" && list[i].disabled_yn != "출고" && list[i].reg_mem_no == "${SecureUser.mem_no}") {
					arr.push(list[i].code);
				}
				if (list[i].disabled_yn != "출고" && (list[i].reg_mem_no == "${SecureUser.mem_no}" || list[i].reg_mem_no == "")) {
					yArr.push(list[i].code);
				}
			}
			AUIGrid.addCheckedRowsByIds(auiGrid, arr);
			if (arr.length > 0 && arr.length == yArr.length) {
				allChecked = true;
				AUIGrid.setAllCheckedRows(auiGrid, allChecked);
			}
			
			// 전체 체크박스 클릭 이벤트 바인딩
			AUIGrid.bind(auiGrid, "rowAllChkClick", function( event ) {
				if(event.checked) {
					// code 의 값들 얻기
					/* var uniqueValues = AUIGrid.getColumnDistinctValues(event.pid, "code"); */
					// Anna 제거하기
					/* uniqueValues.splice(uniqueValues.indexOf("code"),1); */
					var arr = [];
					var list = AUIGrid.getGridData(auiGrid);
					for (var i = 0; i < list.length; ++i) {
						if (list[i].disabled_yn != "출고" && (list[i].reg_mem_no == "${SecureUser.mem_no}" || list[i].reg_mem_no == "")) {
							arr.push(list[i].code);
							AUIGrid.updateRowsById(auiGrid, {disabled_yn : reasonList[0], code : list[i].code, reg_mem_name : "${SecureUser.kor_name}"});
						}
					}
					AUIGrid.setCheckedRowsByValue(event.pid, "code", arr);
				} else {
					AUIGrid.setCheckedRowsByValue(event.pid, "code", []);
					var list = AUIGrid.getGridData(auiGrid);
					for (var i = 0; i < list.length; ++i) {
						if (list[i].disabled_yn != "출고" && (list[i].reg_mem_no == "${SecureUser.mem_no}" || list[i].reg_mem_no == "")) {
							AUIGrid.updateRowsById(auiGrid, {disabled_yn : "", code : list[i].code, reg_mem_name : ""});
						}
					}
				}
				
			});
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
        <div class="title-wrap">
        	<fmt:parseDate value="${inputParam.s_receive_plan_dt}" var="date" pattern="yyyyMMdd"/>
			<h4><fmt:formatDate value="${date}" pattern="yyyy-MM-dd"/> ${org_name} 출하예정시간</h4>
			<c:if test="${empty inputParam.s_out_org_code}"><span style="color: red">기타센터는 출하예정시간을 제한안함</span></c:if>
		</div>
<!-- 폼테이블 -->						
			<div id="auiGrid"></div>
			<div class="btn-group mt5">
         <div class="right">
         	<c:if test="${inputParam.parent_js_name eq 'fnRefresh'}">
         		<button type="button" id="_goSave" class="btn btn-info" onclick="javascript:goSave();">출고불가설정</button>
         	</c:if>
             <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
                 <jsp:param name="pos" value="BOM_R"/>
             </jsp:include>
         </div>
     </div>	
        </div>
    </div>
</form>
</body>
</html>