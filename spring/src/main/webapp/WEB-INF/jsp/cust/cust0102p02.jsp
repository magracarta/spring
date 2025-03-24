<%@ page contentType="text/html;charset=utf-8" language="java"%><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객
-- 작성자 : 박예진
-- 최초 작성일 : 2020-01-20 13:01:58
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
</head>
	<!-- script -->
	<script type="text/javascript">
		$(document).ready(function() {
			createAUIGrid();
		})
		
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid", 
				// rowNumber 
				showRowNumColumn: false,
				// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
				wrapSelectionMove : false,
				showStateColumn : false,
				editable : false
			};
			var columnLayout = [
				{ 
					headerText : "관리번호", 
					dataField : "machine_doc_no", 
					style : "aui-center",
					editable : false,
					width : "30%",
					labelFunction : function(rowIndex, columnIndex, value){
						return value.substring(0, 11);
					},
				},
				{ 
					headerText : "출하일", 
					dataField : "out_proc_date",  
					dataType : "date",
					formatString : "yy-mm-dd HH:MM:ss",
					style : "aui-center",
					width : "45%",
					editable : false,
				},
				{
					headerText : "처리자", 
					dataField : "out_mem_name", 
					style : "aui-center",
					editable : false
				}
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, ${list});
			$("#auiGrid").resize();
		}
		
		function fnClose() {
			window.close(); 
		}
		
	</script>
<body class="bg-white">
<!-- /script -->
<!-- 여기에 content-wrap 삽입 -->
	<div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
            <!-- <button type="button" class="btn btn-icon"><i class="material-iconsclose"></i></button> -->
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
<!-- 폼테이블 -->				
            <div class="title-wrap">
                <h4>관리번호 변경이력</h4>
            </div>			
			<div style="margin-top: 5px; height: 300px;" id="auiGrid"></div>
<!-- /회원구분정책 -->	
			<div class="btn-group mt10">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
        </div>
    </div>
<!-- /content-wrap -->	
</body>
</html>