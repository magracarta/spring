<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 서비스 > Warranty적용 환율관리 > null > null
-- 작성자 : 담당자 이름을 넣어주세요.
-- 최초 작성일 : 2020-04-28 10:05:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	<%-- 여기에 스크립트 넣어주세요. --%>
	
	var auiGrid;
	$(document).ready(function() {
		createAUIGrid();
	});
	
	function createAUIGrid() {
		var gridPros = {
				editable : true,
				// rowIdField 설정
				rowIdField : "_$uid", 
				// rowIdField가 unique 임을 보장
				rowIdTrustMode : true,
				// rowNumber 
				showRowNumColumn : true,
				enableSorting : true,
				showStateColumn : true
		};
		var columnLayout = [
			{

				headerText : "적용일", 
				dataField : "a", 
				dataType : "date",
				width : "15%",
				style : "aui-center",
				dataInputString : "yyyymmdd",
				formatString : "yyyy-mm-dd",
				editRenderer : {
					type : "JQCalendarRenderer", // datepicker 달력 렌더러 사용
					defaultFormat : "yyyymmdd", // 원래 데이터 날짜 포맷과 일치 시키세요. (기본값: "yyyy/mm/dd")
					onlyCalendar : false, // 사용자 입력 불가, 즉 달력으로만 날짜입력 ( 기본값: true )
					maxlength : 8,
					onlyNumeric : true, // 숫자만
					validator : function(oldValue, newValue, rowItem) { // 에디팅 유효성 검사
						return fnCheckDate(oldValue, newValue, rowItem);
					},
					showEditorBtnOver : true
				},
				editable : true
			}, 
			{
				headerText : "＄",
				dataField : "b", 
				dataType : "numeric",
				width : "20%",
				formatString : "#,##0",
				style : "aui-center",
				editable : true,
				required : true
			},
			{
				headerText : "￥",
				dataField : "c", 
				dataType : "numeric",
				width : "20%",
				formatString : "#,##0",
				style : "aui-center",
				editable : true,
				required : true
			},
			{
				headerText : "정렬순서",
				dataField : "d", 
				dataType : "numeric",
				width : "20%",
				style : "aui-center",
				editable : true,
				required : true
			},			
			{
				headerText : "사용여부", 
				dataField : "e", 
				width : "15%", 
				style : "aui-center",
				renderer : {
					type : "CheckBoxEditRenderer",
					editable : true,
					checkValue : "Y",
					unCheckValue : "N"
				}
			},
			{ 
				headerText : "삭제", 
				dataField : "f",
				renderer : {
					type : "ButtonRenderer",
					onClick : function(event) {
						// var popupDelete = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=750, left=0, top=0";
						alert("삭제");
						// $M.goNextPage('/sale/sale0101p01', "", {popupStatus : poppupOption});
					}
				},
				editable : false,
				style : "aui-center"
			}
		]
		
		var testArr = [];
		var testObject = {

					"a" : "2019-10-22",
					"b" : "900",
					"c" : "8000",
					"d" : 1,
					"e" : "Y",
					"f" : "삭제"

		};
		// 테스트데이터 배열로 생성
		for (var i = 0; i < 5; ++i) {
			var tempObject = $.extend(true,{},testObject);
			console.log(testObject);
			testObject.d += 1;
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
	}
	
	function fnAdd(){
		alert("행추가")
	}
	
	function goSearch() {
		alert("조회");
	}
	
 	function goSave() {
		
 		alert('저장');

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
			<div class="contents" style="width : 60%;" >
	<!-- 기본 -->					
				<div class="search-wrap">
						<table class="table table-fixed">
							<colgroup>
								<col width="60px">
								<col width="120px">
								<col width="*">
							</colgroup>
							<tbody>
								<tr>								
									<th>적용일자</th>
									<td>
										<div class="input-group width140px">																			
											<input type="text" class="form-control border-right-0  calDate" id="s_start_dt" 
													name="s_start_dt" dateformat="yyyy-MM-dd" alt="요청시작일" 
													value="${inputParam.s_current_dt}">	
										</div>
									</td>				
									<td class="">
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
				<div id="auiGrid" style="margin-top: 5px; height: 480px;""></div>
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