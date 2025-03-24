<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 계약관리 > 출하명세서-보유장비대비 > null > 계약품의서
-- 작성자 : 손광진
-- 최초 작성일 : 2020-09-18 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		$(document).ready(function(){
			createAUIGrid();
		});
		
		// 마스킹 체크시 조회
		function goSearch() {
			var param = {
				"machine_name" : "${inputParam.machine_name}",
				"s_masking_yn" : $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N",
			};
			
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result){
					if(result.success){
						AUIGrid.setGridData(auiGrid, result.list);
						$("#total_cnt").html(result.total_cnt);
					}
				}
			); 
		}

		//엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "계약품의서", "");
		}
		
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				height : 565
			};
			var columnLayout = [
				{
					headerText : "등록일자", 
					dataField : "doc_dt", 
					dataType : "date",  
					width : "80",
					minWidth : "70",
					style : "aui-center",
					formatString : "yy-mm-dd"
				},
				{ 
					headerText : "관리번호", 
					dataField : "machine_doc_no", 
					width : "90",
					minWidth : "90",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						return value.substring(4, 11);
					},
					style : "aui-center aui-popup"
				},
				{ 
					headerText : "처리자", 
					dataField : "doc_mem_name", 
					width : "80",
					minWidth : "60",
					style : "aui-center"
				},
				{ 
					headerText : "고객명", 
					dataField : "cust_name", 
					width : "100",
					minWidth : "90",
					style : "aui-center"
				},
				{ 
					headerText : "휴대폰", 
					dataField : "hp_no", 
					width : "130",
					minWidth : "90",
					style : "aui-center",
				},
				{ 
					headerText : "계약금액", 
					dataField : "sale_amt", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "100",
					minWidth : "90",
					style : "aui-right"
				},
				{ 
					headerText : "인도예정일", 
					dataField : "receive_plan_dt", 
					dataType : "date",  
					width : "100",
					minWidth : "90",
					style : "aui-center",
					formatString : "yyyy-mm-dd"
				},
				<c:if test="${'Y' eq inputParam.s_pre_yn and not empty inputParam.parent_js_name}">
				{
					headerText : "지정",
					dataField : "pre",
					width : "90",
					minWidth : "90",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							if (opener == null || "${inputParam.s_machine_seq}" == "" || "${inputParam.parent_js_name}" == "") {
								alert("비정상 접근");
								fnClose();
								return false;
							}
							var msg = event.item.machine_doc_no+" 품의서를 "+"${inputParam.s_body_no}"+"차대로\n지정출고 하시겠습니까?";
							/* if ("${inputParam.s_sale_turn_machine_doc_no}" == "") {
								msg += "\n확인을 누르면 즉시 지정되며, 출하순번관리에도 연결됩니다.";
							} */
							if (confirm(msg) == false) {
								return false;
							} else {
								var param = {
									machine_seq : "${inputParam.s_machine_seq}",
									machine_doc_no : event.item.machine_doc_no,
									rowIndex : "${inputParam.s_rowIndex}"
								}
								opener.${inputParam.parent_js_name}(param);
								window.close();	
							}
						}
					},
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						return '지정'
					},
					style : "aui-center",
					editable : true
				}
				</c:if>
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, listJson);

			AUIGrid.bind(auiGrid, "cellClick", function(event){
				
				if(event.dataField == "machine_doc_no") {
					var param = {
						machine_doc_no : event.item.machine_doc_no,
					}
					var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1300, height=750, left=0, top=0";
					$M.goNextPage('/sale/sale0101p01', $M.toGetParam(param), {popupStatus : poppupOption});					
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
					<c:choose>
						<c:when test="${'Y' eq inputParam.s_pre_yn and empty inputParam.s_sale_turn_machine_doc_no }">
							<h4>계약품의서목록-결재완료 상태의 계약품의서만 조회됩니다.</h4>
						</c:when>
						<%-- <c:when test="${'Y' eq inputParam.s_pre_yn and not empty inputParam.s_sale_turn_machine_doc_no }">
							<h4>계약품의서목록-출하순번관리에 등록된 품의서만 조회, 결재완료된 것만 나옴(스탁제외)</h4>
						</c:when> --%>
						<c:otherwise>
							<h4>계약품의서목록</h4>
						</c:otherwise>
					</c:choose>
					<div class="right">
						<c:if test="${page.add.POS_UNMASKING eq 'Y'}">
						<div class="form-check form-check-inline">
							<input  class="form-check-input"  type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" onchange="javascript:goSearch()">
							<label  class="form-check-input"  for="s_masking_yn" >마스킹 적용</label>
						</div>
						</c:if>
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
					</div>
				</div>
				<div id="auiGrid" style="margin-top: 5px; height: 350px;"></div>				
			</div>
<!-- /폼테이블 -->	
<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5">	
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">${total_cnt}</strong>건
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