<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 발주/납기관리 > 미출하부품현황-수주 > null > null
-- 작성자 : 담당자 이름을 넣어주세요.
-- 최초 작성일 : 2020-01-10 17:06:42
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
				rowIdField : "_$uid",
				showRowNumColumn: true,
				editable : false,
				showStateColumn : true,
				//체크박스 출력 여부
				showRowCheckColumn : true,
				//전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
				    headerText: "수주번호",
				    dataField: "1",
					style : "aui-center  aui-editable"
					
				},
				{
					headerText : "수주일",
					dataField : "2",
					style : "aui-center"
				},
				{
				    headerText: "센터",
				    dataField: "3",
					style : "aui-center"
				},
				{
				    headerText: "담당자",
				    dataField: "4",
					style : "aui-center"
				},
				{
				    headerText: "고객명",
				    dataField: "5",
					style : "aui-center"
				},
				{
				    headerText: "휴대폰",
				    dataField: "6",
				    width: "10%",
					style : "aui-center"
				},
				{
				    headerText: "부품번호",
				    dataField: "7",
				    width: "10%",
					style : "aui-center"
				},
				{
				    headerText: "부품명",
				    dataField: "8",
				    width: "15%",
					style : "aui-left"
				},
				{
				    headerText: "수주수량",
				    dataField: "9",
					style : "aui-center"
				},
				{
				    headerText: "출고수량",
				    dataField: "10",
					style : "aui-center"
				},
				{
				    headerText: "미출고량",
				    dataField: "11",
					style : "aui-center"
				},
				{
				    headerText: "가용재고",
				    dataField: "12",
					style : "aui-center   aui-editable"
				},
				{
				    headerText: "계",
				    dataField: "13",
					style : "aui-center"
				},
				{
				    headerText: "발주중수량",
				    dataField: "14",
					style : "aui-center"
				},
				{
				    headerText: "비고",
				    dataField: "15",
				    width: "20%",
					style : "aui-left"
				},
			];
			
			var testArr = [];
			var testObject = {
					"1" : "2020-0199",
					"2" : "2020-04-01",
					"3" : "평택",
					"4" : "장현석",
					"5" : "변진환",
					"6" : "010-4314-1654",
					"7" : "1725845-4111",
					"8" : "SPACE",
					"9" : "1",
					"10" : "1",
					"11" : "0",
					"12" : "23",
					"13" : "1",
					"14" : "5",
					"15" : "비고 입니다.",
			};
			// 테스트데이터 배열로 생성
			for (var i = 0; i < 5; ++i) {
				var tempObject = $.extend(true,{},testObject);
				tempObject.codeId = i;
	
				testArr.push(tempObject);
			};
	
			// 그리드 출력
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
			// AUIGrid.setGridData(auiGrid, []);
			AUIGrid.setGridData(auiGrid, testArr);
			// AUIGrid.setFixedColumnCount(auiGrid, 8);
			
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				//수주번호 클릭시 수주상세 팝업 호출
				if(event.dataField == "1" ) {
					var params = [{}];
					var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1300, height=840, left=0, top=0";
					$M.goNextPage('/cust/cust0201p01', $M.toGetParam(params), {popupStatus : popupOption});
				}
				//가용재고 클릭시 부품재고상세팝업호출
				if(event.dataField == "12" ) {
					var params = [{}];
					var popupOption = "scrollbars=no, resizable-1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1100, height=800, left=0, top=0";
					$M.goNextPage('/part/part0101p01' + '/part_stock', $M.toGetParam(params), {popupStatus : popupOption});
				}
			
				
			});	
		}
		
		function goSearch(){
			alert("조회");
		}
		
		function go0(){
			alert("수주등록상세 팝업호출");
		}

		function go1(){
			alert("마감");
		}
		
		function go2(){

			var param = {
					's_part_no' : "" 
				};
				openOrderPartPanel('fnSetOrderPartResult',  $M.toGetParam(param));
		}
		
		function go3(){
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
<!-- 검색영역 -->					
					<div class="search-wrap">				
						<table class="table">
							<colgroup>
								<col width="55px">
								<col width="250px">
								<col width="30px">
								<col width="100px">
								<col width="70px">
								<col width="100px">
								<col width="">
							</colgroup>
							<tbody>
						
								<tr>
									<th>수주일</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0  calDate" id="s_start_dt" 
															name="s_start_dt" dateformat="yyyy-MM-dd" alt="요청시작일" 
															value="${inputParam.s_current_dt}">
												</div>
											</div>
											<div class="col-auto">~</div>
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0  calDate" id="s_end_dt" 
															name="s_end_dt" dateformat="yyyy-MM-dd" alt="요청종료일" 
															value="${inputParam.s_current_dt}">
												</div>
											</div>
										</div>
									</td>
									<th>센터</th>
									<td>
										<select class="form-control">
											<option>전체</option>
											<option>전체</option>
										</select>
									</td>
									<th>수주처</th>
									<td>
										<div class="input-group">
											<input type="text" class="form-control border-right-0">
											<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:go0();"><i class="material-iconssearch"></i></button>						
										</div>
									</td>									
									<td>
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
									</td>			
								</tr>										
							</tbody>
						</table>					
					</div>
<!-- /검색영역 -->	
<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<h4>조회결과</h4>
						<div class="btn-group">
							<div class="right">					
								<button type="button" class="btn btn-default" onclick="javascript:go1();"  ><i class="material-iconsdone text-default"  ></i> 마감</button>
								<button type="button" class="btn btn-default" onclick="javascript:go2();" ><i class="material-iconslist_alt text-default"   ></i> 발주요청</button>
								<button type="button" class="btn btn-default" onclick="javascript:go3();" ><i class="icon-btn-excel inline-btn"   ></i>엑셀다운로드</button>
							</div>
						</div>
					</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->
					<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
				</div>						
			</div>		
		</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>