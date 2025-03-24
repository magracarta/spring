<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 발주/납기관리 > 수요예측 > null > Forecase산출내역
-- 작성자 : 담당자 이름을 넣어주세요.
-- 최초 작성일 : 2020-01-10 17:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGrid;

		$(document).ready(function() {
			createAUIGrid();	
		});
		
		function goPartMaster() {
			var poppupOption = "";
			var param = {
				part_no : "${inputParam.part_no}"
			}
			$M.goNextPage('/part/part0701p01', $M.toGetParam(param), {popupStatus : poppupOption});
		}
		
		function goPartInOutHis() {
			var poppupOption = "";
			var param = {
				part_no : "${inputParam.part_no}",
				s_part_move_type_cd_in : "Y",
				s_part_move_type_cd_out : "Y",
				s_part_move_type_cd_move : "Y",
				s_cost_yn : "Y" 
			}
			$M.goNextPage('/part/part0101p02', $M.toGetParam(param), {popupStatus : poppupOption});
		}

		function createAUIGrid() {
			var gridPros = {
					showRowNumColumn: false,
			};
			var columnLayout = [
				{
					headerText : "구분",
					dataField : "gubun",
					applyRestPercentWidth :true
				}
			];
			for (var i = 1; i < 13; ++i) {
				var obj = {
					dataField : "month"+i,
					style : "aui-right",
					dataType : "numeric"
				}
				columnLayout.push(obj);
			}
			columnLayout.push({dataField : "sum", headerText : "합계", style : "aui-right", dataType : "numeric"});
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			
			var year = "${inputParam.s_current_year}";
			var month = "${inputParam.s_current_mon}";
			month = month.substr(4, 6);
			var list = ${fcst}
			var rows = "";
			var sum = 1;
			var num = 1;
			if (month > 2) {
				years = year-1;
				for (i=month; i< 13; i++) {
					var obj = {
						headerText :  years+"/"+i
					}
					AUIGrid.setColumnProp(auiGrid, i-(month-1), { headerText : years+"/"+i } );
					num = i-(month-1)+1
				}
			}
			for (i=num; i<13; i++) {
				AUIGrid.setColumnProp(auiGrid, i, { headerText : year+"/"+(i-(num-1)) } );
			}
			var list = ${fcst}
			console.log(list);
			list[0]["gubun"] = "매출(Y)";
			AUIGrid.setGridData(auiGrid, list);
			
			//////////////////첫번째 열에 기본값 세팅하기   //////////////////
			AUIGrid.addRow(auiGrid, {"gubun" : "X"}, "last");
			AUIGrid.addRow(auiGrid, {"gubun" : "매출*X(XY)"}, "last");
			AUIGrid.addRow(auiGrid, {"gubun" : "XX"}, "last");
			
			//////////////////두번째 행에 기본값 세팅하기  //////////////////
			for (i = 1; i< 13; i++) {
				AUIGrid.setCellValue(auiGrid, 1, "month"+i, i);				
			}
			//////////////////세번째 행에 기본값 세팅하기  //////////////////
			for (i = 1; i< 13; i++) {
				var gob = $M.toNum(AUIGrid.getCellValue(auiGrid, 0, "month"+i)) * $M.toNum(AUIGrid.getCellValue(auiGrid, 1, "month"+i))
				AUIGrid.setCellValue(auiGrid, 2, "month"+i, gob);
			}
			//////////////////네번째 행에 기본값 세팅하기  //////////////////
			for (i = 1; i < 13; i++) {
				num = i + 1;
				nums = num + i; 
				sum = sum + nums; 
				if(i<12){j = i+1}
				if(i==1) {
					AUIGrid.setCellValue(auiGrid, 3, "month1", 1);	
				} else {
					AUIGrid.setCellValue(auiGrid, 3, "month"+j, sum);
				}
			}
			AUIGrid.setCellValue(auiGrid, 3, "month2", 4);
			AUIGrid.setCellValue(auiGrid, 3, "month12", 144);
			
			//////////////////마지막 열에 합계 세팅하기  //////////////////
			var data = AUIGrid.getGridData(auiGrid);
			var sumArray = [];

			for (var i = 0; i < data.length; ++i) {
				sum = 0;
				for (j = 1; j < 13; j++) {
					sum = sum + $M.toNum(AUIGrid.getCellValue(auiGrid, i, "month"+j))
				}
				sumArray.push(sum);
				AUIGrid.setCellValue(auiGrid, i, "sum", sum);
			}
			AUIGrid.resetUpdatedItems(auiGrid);
			fnCalc(sumArray);
		}
		
		// 산출내역 계산
		function fnCalc(sumArray) {
			
			var sumY = sumArray[0];;
			var sumX = sumArray[1];
			var sumXY = sumArray[2];
			var sumXX = sumArray[3];
			
			$(".sumY").html(sumY);
			$(".sumX").html(sumX);
			$(".sumXY").html(sumXY);
			$(".sumXX").html(sumXX);
			
			var a1 = (sumXX*sumY) - (sumX*sumXY);
			var a2 = (12 * sumXX) - (sumX * sumX);
			var a3 = (12 * sumXY) - (sumX * sumY);
			
			$(".a1").text( a1 );
			$(".a2").text( a2 );
			$(".a3").text( a3 );
			$(".a4").text( a2 );
			
			// Q&A 11697 소수점 둘째자리에서 반올림. (음수 0.0 이면 0으로 되도록 추가) 210706 김상덕
			var a4 = Math.round(a1/a2*10)/10;
// 			var a4 =((a1/a2*10)/10).toFixed(1);
// 			if($M.toNum(a4) == 0) {
// 				a4 = $M.toNum(a4);
// 			}
			var a5 = Math.round(a3/a2*10)/10;
// 			var a5 = (a3/a2).toFixed(1);
			
			$(".a5").text( a4 );
			$(".a6").text( a5 );
			
			// (Q&A 11876) 21.09.02 수식 값 오류 수정 박예진 
			$(".result").text(Math.round((a4 + ( a5 * 13 )) * 10)/10);
		}

		function fnClose() {
			window.close();
		}
	</script>
	
	<%
		String line = "<table width='240' height='1'><tr><td bgcolor='black'></td></tr></table>";
		String trim = "&nbsp;&nbsp;&nbsp;";
	%>
	
</head>
<body>
<!-- 팝업 -->
	<div class="popup-wrap width-100per">
	<!-- 메인 타이틀 -->
			<div class="main-title">
				<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
			</div>
	<!-- /메인 타이틀 -->
			<div class="content-wrap">
	<!-- 기본 -->					
				<div>
				<table class="table-border">
					<colgroup>
						<col width="100px">
						<col width="">
						<col width="100px">
						<col width="">
						<col width="100px">
						<col width="">
						<col width="100px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right">부품번호</th>
							<td>
								<input type="text" class="form-control" readonly="readonly" value="${item.part_no }">
							</td>
							<th class="text-right">부품명</th>
							<td>
								<input type="text" class="form-control" readonly="readonly" value="${item.part_name }">
							</td>
							<th class="text-right">규격</th>
							<td>
								<input type="text" class="form-control" readonly="readonly" value="${item.part_stand }">
							</td>
							<th class="text-right">모델</th>
							<td>
								<input type="text" class="form-control" readonly="readonly" value="${item.maker_name }">
							</td>
						</tr>
						<tr>
							<th class="text-right">발주단위</th>
							<td>
								<input type="text" class="form-control text-right" readonly="readonly" value="${item.order_unit }">
							</td>
							<th class="text-right">산출수량</th>
							<td>
								<input type="text" class="form-control text-right width100px" readonly="readonly" value="${inputParam.order_qty}">
							</td>
							<th class="text-right">발주처</th>
							<td colspan="3">
								<input type="text" class="form-control width200px" readonly="readonly" value="${item.cust_name }">
							</td>
						</tr>
						<tr>
							<th class="text-right">예약수량</th>
							<td>
								<input type="text" class="form-control text-right">
							</td>
							<th class="text-right">적요</th>
							<td colspan="5">
								<input type="text" class="form-control">
							</td>
						</tr>
					</tbody>
				</table>
			</div>
	<!-- /기본 -->	
	<!-- 그리드 타이틀, 컨트롤 영역 -->
				<div class="title-wrap mt10">
					<h4>예측내역</h4>
					<div class="btn-group">
						<div class="right"><%-- 버튼위치는 pos param 에 따라 나옴 (없으면 기본 상단나옴) T_CODE.CODE_VALUE='BTN_POS' 참고 --%>
							<button type="button" class="btn btn-default" onclick="javascript:goPartMaster()"><i class="material-iconstextsms text-default"></i>부품코드조회</button>
							<button type="button" class="btn btn-default" onclick="javascript:goPartInOutHis()"><i class="icon-btn-excel inline-btn"></i>부품 입/출고내역</button>
						</div>
					</div>
				</div>
	<!-- /그리드 타이틀, 컨트롤 영역 -->					
				<div id="auiGrid" style="margin-top: 5px; height: 135px;"></div>
				<div class="btn-group mt5">
					<div class="left">
					<center style="text-align: center;">
						<table style="margin: 40px">
							<tr><td rowspan="3" width="60"><center><div style="width:70%;border: 1px solid black">&nbsp;a&nbsp;</div></center></td>
								<td class="tc"> (sumXX * sumY) - (sumX * sumXY) </td>  <td rowspan="3">&nbsp;=&nbsp;</td>
								<td class="tc">(<span class="sumXX"></span> x <span class="sumY"></span>) - (<span class="sumX"></span> x <span class="sumXY"></span>)</td>  <td rowspan="3">&nbsp;=&nbsp;</td> <td class="tc"><span class="a1"></span></td> 
								<td rowspan="3">&nbsp;=&nbsp;</td> <td rowspan="3"><span class="a5"></span></td>
							</tr>
							<tr><td><%=line%></td>  <td><%=line%></td> <td><%=line%></td> </tr>
							<tr><td class="tc"><%=trim%>(N * sumXX) - (sumX * sumX) </td> 
								<td class="tc">(12 x <span class="sumXX"></span>) - (<span class="sumX"></span> x <span class="sumX"></span>)</td> <td class="tc"><span class="a2"></span></td>
							</tr>
							<tr><td>&nbsp;</td></tr>
							<tr><td rowspan="3"><center><div style="width:70%;border: 1px solid black">&nbsp;b&nbsp;</div></center></td>
								<td class="tc"><%=trim%>(N * sumXY) - (sumX * sumY) </td>  <td rowspan="3">&nbsp;=&nbsp;</td> 
								<td class="tc">(12 x <span class="sumXY"></span>) - (<span class="sumX"></span> x <span class="sumY"></span>)</td>  <td rowspan="3">&nbsp;=&nbsp;</td> <td class="tc"><span class="a3"></span></td> 
								<td rowspan="3">&nbsp;=&nbsp;</td> <td rowspan="3"><span class="a6"></span></td>
							</tr>
							<tr><td><%=line%></td>  <td><%=line%></td> <td><%=line%></td> </tr>
							<tr><td class="tc"><%=trim%>(N * sumXX) - (sumX * sumX) </td> 
								<td class="tc">(12 x <span class="sumXX"></span>) - (<span class="sumX"></span> x <span class="sumX"></span>)</td> <td class="tc"><span class="a4"></span></td>
							</tr>
							<tr><td class="tc" colspan="8"><br>FORECAST = a + ( b x 13 ) = <span class="a5"></span>  + ( <span class="a6"></span> x 13) = <span class="result"></span></td></tr>
						</table>
					</center>
					</div>
					<div class="right" style="align-self: flex-start;"><%-- 버튼위치는 pos param 에 따라 나옴 (없으면 기본 상단나옴) T_CODE.CODE_VALUE='BTN_POS' 참고 --%>
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
					</div>
				</div>
	<!-- 그리드 서머리, 컨트롤 영역 -->
	<!-- /그리드 서머리, 컨트롤 영역 -->
			</div>
		</div>		
<!-- /contents 전체 영역 -->	
</div>	
</body>
</html>