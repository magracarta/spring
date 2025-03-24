<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 정비 > 정비지시서 > null > 미처리 정비지시서
-- 작성자 : 성현우
-- 최초 작성일 : 2020-07-10 19:54:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	var auiGrid;
	
	$(document).ready(function() {
		// AUIGrid 생성
		createAUIGrid();
		goSearch();
	});

	function goSearch() {
		var params = {
			"s_start_dt" : "20151231",
			"s_end_dt" : "${inputParam.s_current_dt}",
			"s_org_code" : $M.getValue("s_org_code")
		};

		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(params), {method : "GET"},
			function(result) {
				if(result.success) {
					AUIGrid.setGridData(auiGrid, result.list);
					$("#total_cnt").html(result.total_cnt);
				}
			}
		);
	}

	// 닫기
	function fnClose() {
		window.close();
	}

	//그리드생성
	function createAUIGrid() {
		var gridPros = {
			rowIdField : "_$uid",
			showRowNumColumn: true,
		};
		var columnLayout = [
			{ 
				headerText : "관리번호", 
				dataField : "job_report_no",
				style : "aui-center"
			},
			{
				headerText : "차주명", 
				dataField : "cust_name",
				style : "aui-center"
			},
			{ 
				headerText : "차대번호", 
				dataField : "body_no",
				style : "aui-center"
			},
			{ 
				headerText : "정비사업부", 
				dataField : "org_name",
				style : "aui-center"
			},
			{ 
				headerText : "정비자", 
				dataField : "assign_mem_name",
				style : "aui-center"
			},
			{ 
				headerText : "부품번호", 
				dataField : "part_no",
				style : "aui-center"
			},
			{ 
				headerText : "부품명", 
				dataField : "part_name",
				width : "13%",
				style : "aui-left"
			},
			{ 
				headerText : "접수", 
				dataField : "qty",
				width : "5%",
				style : "aui-center"
			},
			{ 
				headerText : "출고", 
				dataField : "out_qty",
				width : "5%",
				style : "aui-center"
			},
			{ 
				headerText : "사용",
				dataField : "use_qty",
				width : "5%",
				style : "aui-center"
			},
			{ 
				headerText : "반품", 
				dataField : "in_qty",
				width : "5%",
				style : "aui-center"
			},
			{ 
				headerText : "상태", 
				dataField : "job_status_name",
				width : "5%",
				style : "aui-center"
			}
		];

		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		AUIGrid.setGridData(auiGrid, []);
		
		$("#auiGrid").resize();
	}	
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" id="s_org_code" name="s_org_code" value="${inputParam.s_org_code}">
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
<!-- 조회결과 -->
				<div class="title-wrap">
					<h4>조회결과</h4>
				</div>
				<div id="auiGrid" style="margin-top: 5px; height: 300px;"></div>
<!-- /조회결과 -->
			</div>		
<!-- /폼테이블 -->
			<div class="btn-group mt10">
				<div class="left">
					총 <strong id="total_cnt" class="text-primary">0</strong>건
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