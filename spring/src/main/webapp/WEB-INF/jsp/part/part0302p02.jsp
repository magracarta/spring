<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 매입관리 > 부품매입관리 > null > 발주자료참조
-- 작성자 : 성현우
-- 최초 작성일 : 2020-09-26 17:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		
		$(document).ready(function() {
			createAUIGrid();
		});

		//적용
		function goApply() {
			var itemArr = AUIGrid.getCheckedRowItemsAll(auiGrid); // 체크된 그리드 데이터
			console.log(itemArr);
			opener.${inputParam.parent_js_name}(itemArr);
			window.close();
		}

		//팝업 닫기
		function fnClose(){
			window.close(); 
		}
		
		function createAUIGrid() {
			//그리드 생성 _ 선택사항
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn: true,
				editable : false,
				//체크박스 출력 여부
				showRowCheckColumn : true,
				//전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
				// 고정칼럼 카운트 지정
				// fixedColumnCount : 3,
				enableFilter : true
			};

			var columnLayout = [
				{ 
					headerText : "발주번호", 
					dataField : "part_order_no",
					style : "aui-center",
					width : "15%"
				},
				{ 
					headerText : "부품번호", 
					dataField : "part_no", 
					style : "aui-center",
					width : "15%",
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "부품명", 
					dataField : "part_name", 
					style : "aui-left",
					width : "25%"
				},
				{ 
					headerText : "기종", 
					dataField : "maker_name",
					style : "aui-center",
				},
				{ 
					headerText : "단위", 
					dataField : "part_unit", 
					style : "aui-center",
				},
				{ 
					headerText : "현재고", 
					dataField : "current_qty", 
					style : "aui-center",
					dataType : "numeric",
					formatString : "#,##0",
				},
				{ 
					headerText : "수량", 
					dataField : "qty", 
					style : "aui-center",
					dataType : "numeric",
					formatString : "#,##0",
				},
				{ 
					headerText : "단가", 
					dataField : "unit_price", 
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0.00",
				},
				{ 
					headerText : "금액", 
					dataField : "amt",
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0.00",
				},
				{ 
					headerText : "미처리량", 
					dataField : "mi_qty", 
					style : "aui-center",
					dataType : "numeric",
					formatString : "#,##0",
				},
				{ 
					headerText : "비고", 
					// dataField : "delivary_dt",
					dataField : "remark",
					style : "aui-left",
					width : "20%"
				},
				{
					headerText : "순번",
					dataField : "seq_no",
					visible : false
				},
				{
					headerText : "고객번호",
					dataField : "cust_no",
					visible : false
				},
				{
					headerText : "매입처그룹코드",
					dataField : "com_buy_group_cd",
					visible : false
				},
					// 22.10.27 Q&A 15267 생산구분확인
				{
					dataField : "part_production_cd",
					visible : false
				}
			];
			
			
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, ${list});
			$("#total_cnt").html(${total_cnt});
			$("#auiGrid").resize();

			AUIGrid.bind(auiGrid, "cellClick", function (event) {
				// 다중선택시 셀클릭 이벤트 바인딩
				AUIGrid.bind(auiGrid, "cellClick", cellClickHandler);
			});
		}

		// 셀 클릭으로 엑스트라 체크박스 체크/해제 하기
		function cellClickHandler(event) {
			var item = event.item, rowIdField, rowId;
			rowIdField = AUIGrid.getProp(event.pid, "rowIdField"); // rowIdField 얻기
			rowId = item[rowIdField];
			// 이미 체크 선택되었는지 검사
			if (AUIGrid.isCheckedRowById(event.pid, rowId)) {
				// 엑스트라 체크박스 체크해제 추가
				AUIGrid.addUncheckedRowsByIds(event.pid, rowId);
			} else {
				// 엑스트라 체크박스 체크 추가
				AUIGrid.addCheckedRowsByIds(event.pid, rowId);
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
			<!-- 폼테이블 -->
			<div>
				<div class="title-wrap">
					<div class="left">
						<h4>${cust_name}</h4>
						<div class="com-info">${hp_no}</div>
					</div>
				</div>
				<div id="auiGrid" style="height:600px; margin-top: 5px;"></div>
			</div>
			<!-- /폼테이블 -->
			<div class="btn-group mt10">
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">0</strong>건
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