<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 매입관리 > 매입처관리 > null > 매입처 관리부품 관리
-- 작성자 : 박예진
-- 최초 작성일 : 2020-02-10 17:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		$(document).ready(function() {
			createAUIGrid();
			goSearch();
		});
		
		//조회
		function goSearch() { 
			var param = {
					"cust_no" : "${inputParam.cust_no}",
					"cust_name" : "${inputParam.cust_name}",
					"s_deal_mold_cont_no_yn" : $M.getValue("s_deal_mold_cont_no_yn"),
					"s_deal_floor_plan_yn" : $M.getValue("s_deal_floor_plan_yn"),
					"s_deal_ware_qual_ass" : $M.getValue("s_deal_ware_qual_ass")
			};
			console.log(param, "param");
			$M.goNextPageAjax('/part/part0301p01' + '/search', $M.toGetParam(param), {method : 'get'},
				function(result) {
					if (result.success) {
						AUIGrid.setGridData(auiGrid, result.list);
						$("#total_cnt").html(result.total_cnt);
					}
				;
			});
		}
		
		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_cust_name", "s_breg_rep_name"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch();
				};
			});
		}
		
		function createAUIGrid() {
			var gridPros = {
					// rowIdField 설정
					rowIdField : "part_no",
					// 고정칼럼 카운트 지정
					// fixedColumnCount : 2,
					// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
					wrapSelectionMove : false,
					// rowNumber 
					showRowNumColumn: false,
					enableFilter :true,
			};
			var columnLayout = [
				{
					headerText : "부품번호", 
					dataField : "part_no", 
					width : 130, 
					style : "aui-center",
					filter : {
		                showIcon : true
		            }
				},
				{ 
					headerText : "부품명", 
					dataField : "part_name", 
					width : 180, 
					style : "aui-left",
					filter : {
		                showIcon : true
		            }
				},
				{ 
					headerText : "평균매입가", 
					dataField : "in_avg_price", 
					dataType : "numeric",
					formatString : "#,##0",
					width : 100, 
					style : "aui-right"
				},
				{ 
					headerText : "최종매입가", 
					dataField : "last_unit_price", 
					dataType : "numeric",
					formatString : "#,##0",
					width : 100, 
					style : "aui-right",
				},
				{ 
					headerText : "최종매입일", 
					dataField : "last_in_dt", 
					dataType : "date",
					width : 100, 
					style : "aui-center",
					formatString : "yyyy-mm-dd"
				},
				{ 
					headerText : "최초등록일",
					dataField : "use_start_dt", 
					dataType : "date",
					width : 100, 
					style : "aui-center",
					formatString : "yyyy-mm-dd"
				},
				{ 
					headerText : "당해년도매입", 
					dataField : "curr_in_qty", 
					dataType : "numeric",
					formatString : "#,##0",
					width : 100, 
					style : "aui-right"
				},
				{ 
					headerText : "전년도매입", 
					dataField : "be1_in_qty", 
					dataType : "numeric",
					formatString : "#,##0",
					width : 100, 
					style : "aui-right"
				},
	 			{ 
					headerText : "전전년도매입", 
					dataField : "be2_in_qty", 
					dataType : "numeric",
					formatString : "#,##0",
					width : 100, 
					style : "aui-right"
				},
	 			{ 
					headerText : "금형관리번호여부", 
					dataField : "deal_mold_cont_no_yn", 
					width : 100, 
					style : "aui-center"
				},
				{ 
					headerText : "도면보유여부", 
					dataField : "deal_floor_plan_yn", 
					width : 100, 
					style : "aui-center"
				},
				{ 
					headerText : "입고품질검사여부", 
					dataField : "deal_ware_qual_ass", 
					width : 100, 
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var qualYn = "";
						if(value == "0") {
							qualYn = "Y";		// 검사
						} else if (value == "1") {
							qualYn = "N";		// 미검사
						} else {
							qualYn = "N";		// 불요
						}
						return qualYn;
					}
				}
			]
			// 실제로 #grid_wrap 에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, ${list});
		}
		
		//팝업 끄기
		function fnClose() {
			window.close(); 
		}
		
		function fnDownloadExcel() {
			  fnExportExcel(auiGrid, "매입처 관리부품 관리");
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
<!-- 검색조건 -->
			<div class="search-wrap mt10">
				<table class="table">
					<colgroup>
						<col width="100px">
						<col width="190px">
						<col width="90px">
						<col width="190px">
						<col width="90px">
						<col width="190px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
						<th class="text-right">금형보유 여부</th>
							<td>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" id="s_deal_mold_cont_no_yn" name="s_deal_mold_cont_no_yn" value="" checked>
									<label class="form-check-label" for="s_deal_mold_cont_no_yn">전체</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" id="s_deal_mold_cont_no_yn_y" name="s_deal_mold_cont_no_yn" value="Y">
									<label class="form-check-label" for="s_deal_mold_cont_no_yn_y">보유</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" id="s_deal_mold_cont_no_yn_n" name="s_deal_mold_cont_no_yn" value="N">
									<label class="form-check-label" for="s_deal_mold_cont_no_yn_n">미보유</label>
								</div>
							</td>	
							<th class="text-right">도면보유 여부</th>
							<td>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" id="s_deal_floor_plan_yn" name="s_deal_floor_plan_yn" value="" checked>
									<label class="form-check-label" for="s_deal_floor_plan_yn">전체</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" id="s_deal_floor_plan_yn_y" name="s_deal_floor_plan_yn" value="Y">
									<label class="form-check-label" for="s_deal_floor_plan_yn_y">보유</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" id="s_deal_floor_plan_yn_n" name="s_deal_floor_plan_yn" value="N">
									<label class="form-check-label" for="s_deal_floor_plan_yn_n">미보유</label>
								</div>
							</td>	
							<th class="text-right">입고보유 여부</th>
							<td>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio"  id="s_deal_ware_qual_ass" name="s_deal_ware_qual_ass" value="" checked>
									<label class="form-check-label" for="s_deal_ware_qual_ass">전체</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio"  id="s_deal_ware_qual_ass_y" name="s_deal_ware_qual_ass" value="0">
									<label class="form-check-label" for="s_deal_ware_qual_ass_y">검사</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio"  id="s_deal_ware_qual_ass_n" name="s_deal_ware_qual_ass" value="1">
									<label class="form-check-label" for="s_deal_ware_qual_ass_n">미검사</label>
								</div>
							</td>	
							<td class=""><button type="button" class="btn btn-important" style="width: 70px;" onclick="javascript:goSearch();">조회</button></td>
						</tr>
					</tbody>
				</table>
			</div>
<!-- /검색조건 -->
			<div class="title-wrap mt10">
				<h4>조회결과</h4>
				<div class="btn-group">
					<div class="right">
						<button type="button" class="btn btn-default" onclick="javascript:fnDownloadExcel();"><i class="icon-btn-excel inline-btn"></i>엑셀다운로드</button>
					</div>
				</div>
			</div>
<!-- 검색결과 -->
			<div id="auiGrid" style="margin-top: 5px; width: 100%; height: 200px;"></div>
			<div class="btn-group mt5">	
				<div class="left">	
					총 <strong class="text-primary" id="total_cnt">0</strong>건</div>
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
			
<!-- /검색결과 -->
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>