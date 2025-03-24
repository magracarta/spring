<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 고객관리 > 정비이력 키워드검색 > null > 고장부위
-- 작성자 : 최보성
-- 최초 작성일 : 2020-04-07 19:54:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	<%-- 여기에 스크립트 넣어주세요. --%>
	
	var auiGridLeft;
	var auiGridRight;
	
	$(document).ready(function() {
		// AUIGrid 생성
		createAUIGridLeft();
		createAUIGridRight();
	});
	
	// 그리드생성
	function createAUIGridLeft() {
		var gridPros = {
			rowIdField : "row",
			showRowNumColumn : false,
			displayTreeOpen : false
		};
		var columnLayout = [
			{ 
				headerText : "분류", 
				dataField : "break_part_name", 
				style : "aui-center",
			},
			{
				dataField : "break_part_seq",
				visible : false
			}
		];
		
		
		
		auiGridLeft = AUIGrid.create("#auiGridLeft", columnLayout, gridPros);
		AUIGrid.setGridData(auiGridLeft, ${list});
		
		AUIGrid.bind(auiGridLeft, "cellClick", function(event) {
			if(event.dataField == "break_part_name" ) {
				if(event.item.break_part_depth == "2") {
					var params = {
						s_up_break_part_seq : event.item.break_part_seq	
					};
					
					$M.goNextPageAjax(this_page + "/detail", $M.toGetParam(params), { method : 'get'},
						function(result) {
							if(result.success) {          
								$("#total_cnt").html(result.list.length);
								AUIGrid.setGridData(auiGridRight, result.list);
								$("#auiGridRight").resize();
							}
						}
					);
				}
			}
		});	
		
		$("#auiGridLeft").resize();
	}

	// 미결사항 그리드
	function createAUIGridRight() {
		var gridPros = {
			rowIdField : "_$uid",
			showRowNumColumn: true,
			//showRowCheckColumn : true,
			//전체선택 체크박스 표시 여부
			//showRowAllCheckBox : true,
		};
		var columnLayout = [
			{ 
				headerText : "관리코드", 
				dataField : "mng_code", 
				style : "aui-center aui-popup",
			},
			{
				headerText : "고장원인", 
				dataField : "break_part_name", 
				style : "aui-left"
			},
			{
				dataField : "break_part_seq",
				visible : false
			}
		];
	
		
		auiGridRight = AUIGrid.create("#auiGridRight", columnLayout, gridPros);
		AUIGrid.setGridData(auiGridRight, []);
		
		AUIGrid.bind(auiGridRight, "cellClick", function(event) {
			if(event.dataField == "mng_code" ) {
				opener.fnSetBreakInfo(event.item);
			}
		});
		
		$("#auiGridRight").resize();
	}	
	
	// 닫기
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
			<div class="row">
				<div class="col-5">
<!-- 좌측 트리그리드영역 -->
					<div id="auiGridLeft" style="margin-top: 5px; height: 300px;"></div>
<!-- /좌측 트리그리드영역 -->
				</div>
				<div class="col-7">
<!-- 우측 그리드영역 -->
					<div id="auiGridRight" style="margin-top: 5px; height: 300px;"></div>
					<div class="btn-group mt10">
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">0</strong>건
						</div>
					</div>
<!-- /우측 그리드영역 -->
				</div>
			</div>	
			<div class="btn-group">	
				<div class="right">
					<button type="button" class="btn btn-info" onclick="javascript:fnClose();">닫기</button>
				</div>
			</div>		
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>