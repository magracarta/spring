<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 공통업무 > 카드사용 내역관리 > null > null
-- 작성자 : 담당자 이름을 넣어주세요.
-- 최초 작성일 : 2020-04-28 10:05:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	<%-- 여기에 스크립트 넣어주세요. --%>
	$(document).ready(function() {
		createAUIGrid();
	});
	
	//그리드생성
	function createAUIGrid() {
		var gridPros = {
			// 체크박스 출력 여부
			showRowCheckColumn : true,
			// 전체선택 체크박스 표시 여부
			showRowAllCheckBox : true,
			// Row번호 표시 여부			
			showRowNumColum : true,
			editable : true,			
			rowIdField : "_$uid"
		};
		var columnLayout = [
			{
				headerText : "카드번호", 
				dataField : "a",   
				width : "12%", 
				style : "aui-center"
			},
			{
				headerText : "승인일시", 
				dataField : "b", 
				width : "12%", 
				style : "aui-center aui-editable",
				dataType : "date",
				formatString : "yy-mm-dd HH:MM:ss",
				editable : false
			},
			{ 
				headerText : "구분", 
				dataField : "c",
				dataType : "date",   
				width : "7%", 
				style : "aui-center",
				dataType : "date",
				formatString : "yy-mm-dd HH:MM:ss",
				editable : false
			},
			{
				headerText : "가맹점명", 
				dataField : "d", 
				width : "10%", 
				style : "aui-left"
			},
			{ 
				headerText : "승인금액", 
				dataField : "e",
				width : "7%", 
				dataType : "numeric",
				style : "aui-right",
				formatString : "#,##0",
				editable : false
			},
			{ 
				headerText : "공급가", 
				dataField : "f",
				width : "7%", 
				dataType : "numeric",
				style : "aui-right",
				formatString : "#,##0",
				editable : false
			},
			{ 
				headerText : "부가세", 
				dataField : "g",
				width : "7%", 
				dataType : "numeric",
				style : "aui-right",
				formatString : "#,##0",
				editable : false
			},
			{ 
				headerText : "사용자", 
				dataField : "h",  
				width : "8%", 
				style : "aui-center"
			},
			{
				headerText : "비고", 
				dataField : "i", 
				width : "30%", 
				style : "aui-left"
			}
		];
		var testArr = [];
		var testObject = {
				"a" : "9430-0305-1370-8907"
				, "b" : "2020-02-01 02:24:01"
				, "c" : "일반비용"
				, "d" : "후불하이패스 8건"
				, "e" : "14600"
				, "f" : "14600"
				, "g" : "0"
				, "h" : "장현석"
				, "i" : "비고내용이 들어갑니다."

		};

		// 테스트데이터 배열로 생성
		for (var i = 0; i < 5; ++i) {
			var tempObject = $.extend(true,{},testObject);
			tempObject.codeId = i;
			/* if (i != 0){
				tempObject.sheet = "품의서";
			} */
			testArr.push(tempObject);
		};
		
		// 실제로 #grid_wrap에 그리드 생성
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		// 그리드 갱신
		AUIGrid.setGridData(auiGrid, testArr);		
		$("#auiGrid").resize();
		
		AUIGrid.bind(auiGrid, "cellClick", function(event) {
			if(event.dataField == "b") {
				var poppupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=550, height=640, left=0, top=0";
				$M.goNextPage('/mmyy/mmyy0105p01', '', {popupStatus : poppupOption});
			}
		});

	}
	
		function goSearch() {
			alert("조회");
		}
		
		function fnDownloadExcel() {
			alert("엑셀다운로드");
		}
	
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<div class="layout-box">
<!-- contents 전체 영역 -->
	<div class="content-wrap">
		<div class="content-box">
	<!-- 메인 타이틀 -->
			<div class="main-title">
				<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
			</div>
	<!-- /메인 타이틀 -->
			<div class="contents">
	<!-- 기본 -->					
				<div class="search-wrap">				
						<table class="table table-fixed">
							<colgroup>
								<col width="60px">
								<col width="250px">								
								<col width="50px">
								<col width="300px">		
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th>조회기간</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" alt="" value="${inputParam.s_current_dt}">
												</div>
											</div>
											<div class="col-auto">~</div>
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="" value="${inputParam.s_current_dt}">
												</div>
											</div>
										</div>
									</td>
									<th>카드구분</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-4">
												<select class="form-control">
													<option>전체</option>
													<option>전체</option>
												</select>
											</div>
											<div class="col-8">
												<select class="form-control">
													<option>5454-56456-8974-564 장현석</option>
													<option>5454-56456-8974-564 장현석</option>
												</select>
											</div>
										</div>
									</td>
									<td>
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();" >조회</button>
									</td>									
								</tr>						
							</tbody>
						</table>					
					</div>
	<!-- /기본 -->	
	<!-- 그리드 타이틀, 컨트롤 영역 -->
				<div class="title-wrap mt10">
					<h4>조회결과</h4>
					<div class="btn-group">
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
						</div>
					</div>
				</div>
	<!-- /그리드 타이틀, 컨트롤 영역 -->					
				<div id="auiGrid" style="height:480px; margin-top: 5px;"></div>
	<!-- 그리드 서머리, 컨트롤 영역 -->
				<div class="btn-group mt5">
					<div class="left">
						총 <strong class="text-primary">5</strong>건
					</div>						
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
					</div>
				</div>
	<!-- /그리드 서머리, 컨트롤 영역 -->
			</div>
		</div>	
		<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>	
	</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>