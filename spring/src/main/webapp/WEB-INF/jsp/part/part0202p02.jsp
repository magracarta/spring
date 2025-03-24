<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 창고이동/부품출하 > 부품이동처리 > null > 입고창고
-- 작성자 : 손광진
-- 최초 작성일 : 2020-07-03 10:01:33
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function() {
			// 그리드 생성
			createAUIGrid();		
		});
		
		// 그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "part_no",
				showRowNumColumn: true,
				editable : false,
				//체크박스 출력 여부
				showRowCheckColumn : true,
				//전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
				    headerText: "부품번호",
				    dataField: "part_no",
					width : "25%",
					style : "aui-center"
				},
				{
					headerText : "부품명",
					dataField : "part_name",
					style : "aui-left"
				},
				{
				    headerText: "재고",
				    dataField: "current_stock",
				    dataType : "numeric",
					formatString : "#,##0",
					width : "10%",
					style : "aui-center"
				},
				{
				    headerText: "매입처",
				    dataField: "cust_name",
					width: "25%",
					style : "aui-center"
				},
				{
				    dataField: "storage_name",
				    visible : false,
				},
			];

			// 그리드 출력
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, ${partList});
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				// Row행 클릭 시 반영
				try {
					var item = [];
					item.push(event.item);
					if(opener.${inputParam.parent_js_name}(item) != undefined) {
						alert(opener.${inputParam.parent_js_name}(item));
						return false;
					};
				} catch(e) {
					alert('호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.');
				}

			});
		}
		
		//팝업 닫기
		function fnClose(){
			window.close(); 
		}
		

		// 적용
		function goApply() {
			var itemArr = AUIGrid.getCheckedRowItemsAll(auiGrid); // 체크된 그리드 데이터
			var item = [];
			
			if(itemArr.length == 0){
				alert("선택된 부품이 없습니다.");
				return;
			};
			
			for(var i = 0; i < itemArr.length; i++) {
				item.push(itemArr[i]);				
			};
			
			try {
				opener.${inputParam.parent_js_name}(item);
				window.close();
			} catch(e) {
				alert('호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.');
			}
			
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
		        </div>
		<!-- /타이틀영역 -->
		        <div class="content-wrap">  
					<div class="title-wrap">
						<h4>재고명세</h4>
						<div>
							<button type="button" class="btn btn-default" onclick="javascript:goApply();"><i class="material-iconsdone text-default"></i>적용</button>
						</div>
					</div>
		<!-- 검색결과 -->
					<!-- 그리드 생성 -->
					<div id="auiGrid" style="margin-top: 5px; height: 470px;"></div>		
					
					<div class="btn-group mt5">	
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">${total_cnt}</strong>건
						</div>						
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>
					</div>
		<!-- /검색결과 -->
		        </div>
		    </div>
		<!-- /팝업 -->	
	</form>
</body>
</html>