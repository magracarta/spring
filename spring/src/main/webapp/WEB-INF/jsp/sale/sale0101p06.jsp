<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 계약관리 > 계약/출하 > null > 출하장비선택
-- 작성자 : 김태훈
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		$(document).ready(function() {
			createAUIGrid();
		});
		
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "machine_seq",
				height : 555,
				rowStyleFunction : function(rowIndex, item) {
            		if (item.pre_machine_doc_no != "" && item.pre_machine_doc_no != "${inputParam.machine_doc_no}") {
						return "aui-status-complete";
            		}
            	}
			};
			var visibles = false
			var columnLayout = [
				{ 
					headerText : "차대번호", 
					dataField : "body_no", 
					width : "20%", 
					style : "aui-center"
				},
				{ 
					headerText : "엔진번호1", 
					dataField : "engine_no_1",
					width : "10%", 
					style : "aui-center"
				},
				{
					headerText : "장비명", 
					dataField : "machine_name", 
					width : "10%", 
					style : "aui-center"
				},
				{ 
					headerText : "통관일자", 
					dataField : "pass_dt", 
					dataType : "date",
					width : "10%", 
					style : "aui-center",
					formatString : "yyyy-mm-dd"
				},
				{ 
					headerText : "입고일자", 
					dataField : "in_dt", 
					dataType : "date",
					width : "10%", 
					style : "aui-center",
					formatString : "yyyy-mm-dd"
				},
				{ 
					headerText : "출고일자", 
					dataField : "sale_dt", 
					dataType : "date",
					width : "10%", 
					style : "aui-center",
					formatString : "yyyy-mm-dd"
				},
				{ 
					headerText : "보관센터", 
					dataField : "in_org_name", 
					width : "8%", 
					style : "aui-center",
				},
				{ 
					headerText : "판매일자", 
					dataField : "sale_dt", 
					dataType : "date",
					width : "10%", 
					style : "aui-center",
					formatString : "yyyy-mm-dd"
				},
				{ 
					headerText : "계산서일", 
					dataField : "taxbill_dt", 
					dataType : "date",
					width : "10%", 
					style : "aui-center",
					formatString : "yyyy-mm-dd"
				},
				{ 
					headerText : "구분", 
					dataField : "machine_out_pos_status_name", 
					width : "6%", 
					style : "aui-center",
				},
				{ 
					headerText : "상태", 
					dataField : "machine_status_name", 
					width : "6%", 
					style : "aui-center",
				},
				{ 
					headerText : "스탁여부", 
					dataField : "machine_doc_no", 
					width : "15%", 
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
					     return value != null && value != "" ? "STOCK "+value : ""; 
					},
					style : "aui-center",
				},
				{
					dataField : "machine_seq",
					visible : visibles
				},
				{ 
					dataField : "engine_no_2",
					visible : visibles
				},
				{ 
					dataField : "engine_model_1",
					visible : visibles
				},
				{ 
					dataField : "engine_model_2",
					visible : visibles
				},
				{ 
					dataField : "opt_model_1",
					visible : visibles
				},
				{ 
					dataField : "opt_model_2",
					visible : visibles
				},
				{ 
					dataField : "opt_no_1",
					visible : visibles
				},
				{ 
					dataField : "opt_no_2",
					visible : visibles
				},
				{
					dataField : "pre_machine_doc_no",
					visible : visibles
				},
				{
					dataField : "pre_cust_name",
					visible : visibles
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, ${toOut});
			var cnt = AUIGrid.getGridData(auiGrid).length;
			$("#total_cnt").html(cnt);
			// AUIGrid.setFixedColumnCount(auiGrid, 3);
			AUIGrid.bind(auiGrid, "cellClick", function(event){
				try{
					if (event.item.pre_machine_doc_no != undefined && event.item.pre_machine_doc_no != "" && event.item.pre_machine_doc_no != "${inputParam.machine_doc_no}") {
						alert("선택한 장비는 "+event.item.pre_cust_name+"고객에게 이미 지정 된 장비입니다.\n다른 장비를 선택하세요!");
						return false;
					}
					
					// (Q&A 12185) 고객정보 출하스티커 추가 211020 김상덕
					if ("Y" != "${inputParam.cust_print_yn}") {
						// if (confirm("차대번호를 한번 더 확인해주세요.\n"+event.item.body_no+" 가 맞습니까?\n해당 출하장비로 계약출하순번관리 품의서가 변경됩니다.") == false) {

						// (3-2차 Q&A 14493) 계약출하순번관리 리뉴얼로 인하여 confirm창에 계약출하순번관리 관련 문구 삭제
						if (confirm("차대번호를 한번 더 확인해주세요.\n"+event.item.body_no+" 가 맞습니까?") == false) {
			        		return false;
			        	}
					}
					opener.${inputParam.parent_js_name}(event.item);
					window.close();	
				} catch(e) {
					alert('호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.');
				}
			});
			$("#auiGrid").resize();
		}
		
		function fnClose() {
			window.close();
		}
	
	</script>
</head>
<body class="bg-white">
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
				<div class="title-wrap">
					<h4 class="primary">출하장비선택</h4>
				</div>				
				<div id="auiGrid" style="margin-top: 5px;"></div>
			</div>
			<div class="btn-group mt5">
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">0</strong>건
				</div>
                <div class="right">
                	<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>	
                </div>
            </div>
<!-- /폼테이블 -->
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>