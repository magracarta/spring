<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 공통업무팝업 > 공통업무팝업 > null > 거래시필수확인사항 > 과거이력
-- 작성자 : 류성진
-- 최초 작성일 : 2022-09-19
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<style>
		/* by.재호 */
		/* 커스텀 에디터 스타일 */
		#textAreaWrap {
			font-size: 12px;
			position: absolute;
			height: 100px;
			min-width: 100px;
			background: #fff;
			border: 1px solid #555;
			display: none;
			padding: 4px;
			text-align: right;
			z-index: 9999;
		}

		#textAreaWrap textarea {
			font-size: 12px;
		}
	</style>
	<script type="text/javascript">
		var auiGrid;

		$(document).ready(function() {

			// 그리드 생성
			createAUIGrid();
			fnInitTotalCnt();

			// by.재호
			// textarea blur
			$("#myTextArea").blur(function (event) {
				var relatedTarget = event.relatedTarget || document.activeElement;
				var $relatedTarget = $(relatedTarget);

				forceEditngTextArea(this.value);
			});
		});

		function fnInitTotalCnt() {
			$("#total_cnt").html("${total_cnt}");
		}
		// 그리드 빈값 체크
		function fnCheckGridEmpty() {
			return AUIGrid.validateGridData(auiGrid, ["memo_text"], "필수 항목은 반드시 값을 입력해야합니다.");
		}
		

		// 그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn: true,
				editable : false,
				// showStateColumn : true,
				height : 400,
				wordWrap : true,
				// 고정할 행 높이
				rowHeight : 120,
			};
			
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
				    headerText: "등록일자",
				    dataField: "reg_date",
					dataType : "date",
					formatString : "yyyy/mm/dd",
				    editable : false,
					width : "8%",
					style : "aui-center"
				},
				{
					headerText : "등록자",
					dataField : "reg_mem_name",
				    editable : false,
					width: "5%",
					style : "aui-center"
				},
				{
				    headerText: "메모",
				    dataField: "memo_text",
				    editable : false,
				    wrapText : true,
					width : "35%",
					style : "aui-left",
					renderer: {
						type: "TemplateRenderer"
					},
					editRenderer : {
						type : "InputEditRenderer",
						// 에디팅 유효성 검사
						maxlength : 300,
						validator : AUIGrid.commonValidator
					},
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						return "aui-left";
					}
				},
				{
				    headerText: "처리사유",
				    dataField: "status_memo",
				    editable : false,
					width : "*",
					style : "aui-left",
					renderer: {
						type: "TemplateRenderer"
					},
					editRenderer : {
						type : "InputEditRenderer",
						// 에디팅 유효성 검사
						maxlength : 300,
						validator : AUIGrid.commonValidator
					},
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						return "aui-left";
					}
				},
				{
				    headerText: "구분",
				    dataField: "cust_memo_status_name",
				    editable : false,
					width : "5%",
					style : "aui-center",
				},
				{
				    headerText: "처리일자",
					dataField: "upt_date",
					dataType : "date",
					formatString : "yyyy/mm/dd",
					editable : false,
					width : "8%",
					style : "aui-center"
				},
                {
                    headerText : "처리자",
                    dataField : "upt_mem_name",
                    editable : false,
                    width: "5%",
                    style : "aui-center"
                }
			];

			// 그리드 출력
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, custMemoListJson);
			AUIGrid.bind(auiGrid, "cellEditBegin", function(event) {
				if(event.dataField == "memo_text" || event.dataField == "seq_no") {
					// 메모를 등록한 사용자만 수정/삭제 가능
					if(event.item.reg_mem_no == "${SecureUser.mem_no}") {
						// 커스템 에디터 출력
						createMyCustomEditRenderer(event);
						return false;
					} else {
						setTimeout(function() {
							   AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "등록자가 아닌 경우 수정할 수 없습니다.");
						}, 1);
						createMyCustomEditRenderer(event);
						return false; // false 반환하면 기본 행위 안함(즉, cellEditBegin 의 기본행위는 에디팅 진입임)
					};
				};
			});
			$("#auiGrid").resize();
		}
		
		//팝업 닫기
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
        	<!-- <h2>거래시 필수확인사항</h2> -->
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">  
			<div class="title-wrap">
				<h4>과거이력</h4>
			</div>
<!-- 검색결과 -->
			<!-- 그리드 생성 -->
			<div id="auiGrid" style="margin-top: 5px;"></div>		
			
			<div class="btn-group mt5">	
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">0</strong>건
				</div>						
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
<!-- /검색결과 -->
        </div>
    </div>
<!-- /팝업 -->
	<!-- 사용자 정의 렌더러 - html textarea 태그 -->
	<div id="textAreaWrap">
		<textarea id="myTextArea" class="aui-grid-custom-renderer-ext" style="width:100%; height:90px;"></textarea>
	</div>
</form>
</body>
</html>