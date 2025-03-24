<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 부품통계 > KPI집계 > null > null
-- 작성자 : 김태훈
-- 최초 작성일 : 2021-04-09 14:09:45
-- ETC는 재고 조회불가 -> ETC데이터는 안나옴
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		var monArr = ["12", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11"];
		var monthArr = [];
		var makerJosnTemp = [];
		var makerJosn = [];
		
		$(document).ready(function() {
			
			makerJsonTemp = JSON.parse('${codeMapJsonObj['MAKER_STAT']}');
			var initArr = [];
			for (var i = 0; i < makerJsonTemp.length; ++i) {
				if (makerJsonTemp[i].use_yn == "Y") {
					makerJosn.push(makerJsonTemp[i]);
					initArr.push(makerJsonTemp[i].code_value);
				}
			}
			$M.setValue("s_maker_cd", initArr);
			
			// 그리드 생성
			createAUIGrid();
			setBranchColumnProp();
		});
		
		// 비교군 팝업
		function goControlGroupPopup() {
			var param = {
				s_year : $M.getValue("s_year"),
				s_maker_cd_str 	: $M.getValue("s_maker_cd"),
			}
			if (param.s_maker_cd_str == "") {
				alert("메이커를 선택해주세요.");
				return false;
			}
			var popupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=700, left=0, top=0";
			$M.goNextPage("/part/part0607p01", $M.toGetParam(param), {popupStatus : popupOption});
		}
		
		// 외자부품확인 팝업
		function goForeignPopup() {
			var param = {
				s_year : $M.getValue("s_year"),
			}
			if (param.s_year == "") {
				alert("연도를 선택해주세요.");
				return false;
			}
			var popupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=700, left=0, top=0";
			$M.goNextPage("/part/part0607p04", $M.toGetParam(param), {popupStatus : popupOption});
		}
		
		// 브랜치 헤더 속성값 변경하기
		function setBranchColumnProp() {
			// 데이터 필드가 myGroupField 인 헤더 속성값 변경하기
			for (var i = 1; i < 13; ++i) {
				var str = $M.getValue("s_year");
				if (i == 1) {
					str = $M.toNum($M.getValue("s_year"))-1;
				}
				str+="-"+monArr[i-1];
				AUIGrid.setColumnPropByDataField(auiGrid, "month_"+$M.lpad(i, 2, "0"), {
					headerText : str,
				});
			}
		};
		
		function goSearch() {
			var param = {
				s_year 			: $M.getValue("s_year"),
				s_maker_cd_str 	: $M.getValue("s_maker_cd"),
			};
			
			if (param.s_maker_cd_str == "") {
				alert("메이커를 선택해주세요.");
				return false;
			}
			
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						AUIGrid.setGridData(auiGrid, result.list);
					};
					setBranchColumnProp();
				}
			);
		}
		
		//엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "KPI집계-메이커", "");
		}
		
		//그리드 스타일을 동적으로 바꾸기
	 	function myCellStyleFunction(rowIndex, columnIndex, value, headerText, item, dataField) {
           	if (item.col == "매출") {
             	return "aui-popup";
            } 
        };

		
		// 그리드생성
		function createAUIGrid() {
			var gridPros = {
				showRowNumColumn : false,
				rowIdField : "_$uid",
	            // 그룹핑 후 셀 병합 실행
	            enableCellMerge : true,
	            enableSorting  : false
	            
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
					dataField: "maker_stat_cd",
					visible : false
				},
				{
				    headerText: "메이커",
				    dataField: "maker_stat_name",
					width : "90",
					minWidth : "90",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var ret = value;
						for (var i = 0; i <makerJosn.length; ++i) {
							if (makerJosn[i].code_value == value) {
								ret = makerJosn[i].code_name;
							}
						}
						if (ret == null) {
							ret = "Total";
						}
						return ret;
					},
					cellMerge : true,
					colSpan : 2
				},
				{
				    dataField: "col",
					width : "95",
					minWidth : "95"
				},
			];
			
			for (var i = 0; i < 12; ++i) {
				var mon = "month_"+$M.lpad(i+1, 2, '0');
				columnLayout.push(
						{
							dataField : mon,
							style : "aui-right",
							styleFunction: myCellStyleFunction,
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								return value == null || value == "0" ? "" : $M.setComma(value)
							},
						}
				);
				monthArr.push(mon);
			}
			
			// 푸터레이아웃
			var footerColumnLayout = [];
	
			// 그리드 출력
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, []);
			
			AUIGrid.setFooter(auiGrid, footerColumnLayout);
			$("#auiGrid").resize();
			// 클릭 시 팝업페이지 호출
 			AUIGrid.bind(auiGrid, "cellClick", function(event) {
 				if(monthArr.indexOf(event.dataField) > -1 && event.item.col == "매출") {
 					var headerText = AUIGrid.getColumnItemByDataField(auiGrid, event.dataField).headerText;
 					var year = headerText.split("-")[0];
 					var mon = headerText.split("-")[1];
 					var lastDay = new Date(year, $M.toNum(mon), 0).getDate();
 					
 					var param = {
 						s_start_dt : year+mon+"01",
 						s_end_dt : year+mon+lastDay,
 						part_production_oke : "계",
 						maker_stat_cd : event.item.maker_stat_cd == "Total" ? "" : event.item.maker_stat_cd,
 						maker_stat_name : event.item.maker_stat_name  == undefined ? "Total" : event.item.maker_stat_name,
 					}
 					
 					var popupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=700, left=0, top=0";
					$M.goNextPage("/part/part0601p01", $M.toGetParam(param), {popupStatus : popupOption});
 				}
			});
		}
		
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<div class="layout-box">
<!-- contents 전체 영역 -->
		<div class="content-wrap">
<!-- 검색영역 -->		
					<div class="search-wrap mt10">
						<table class="table">
							<colgroup>
								<col width="70px">
								<col width="100px">
								<col width="10px">
								<col width="50px">
							</colgroup>
							<tbody>
								<tr>								
									<th>기준년도</th>
									<td>
										<select class="form-control width120px" name="s_year" id="s_year">
											<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
												<option value="${i}" <c:if test="${i eq inputParam.s_current_year}">selected="selected"</c:if>>${i}년</option>
											</c:forEach>
										</select>
									</td>
									<td class="">
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
									</td>
									<th>메이커</th>
									<td>
										<input type="text" style="width : 500px";
											id="s_maker_cd" 
											name="s_maker_cd" 
											easyui="combogrid"
											header="Y"
											easyuiname="makerName" 
											panelwidth="140"
											maxheight="300"
											textfield="code_name"
											multi="Y"
											idfield="code_value" />
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
								<button type="button" class="btn btn-default" onclick="javascript:goForeignPopup();">외자부품확인</button>
								<button type="button" class="btn btn-default" onclick="javascript:goControlGroupPopup();">비교군</button>
								<button type="button" id="_fnDownloadExcel" class="btn btn-default" onclick="javascript:fnDownloadExcel();"><i class="icon-btn-excel inline-btn"></i>엑셀다운로드</button>
							</div>
						</div>
					</div>
					
<!-- /그리드 타이틀, 컨트롤 영역 -->
					<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
				</div>						
			</div>		
<!-- /contents 전체 영역 -->	
</form>
</body>
</html>