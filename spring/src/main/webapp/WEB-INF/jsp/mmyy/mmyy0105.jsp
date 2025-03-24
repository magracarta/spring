<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 법인카드 사용이력 > null > null
-- 작성자 : 박준영
-- 최초 작성일 : 2020-05-14 14:51:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	
	<style type="text/css">
	
		/* 커스텀 행 스타일 ( 회계확인 ) */
		.my-row-style1 {
			color:#bbbbbb;
		}
	
		/* 커스텀 행 스타일 (승인취소) */
		.my-row-style2 {
			color:red;
		}
	
		/* 커스텀 행 스타일 법인카드(정상매출) */
		.my-row-style3 {
			color:#31933d;
		}
		
		/* 커스텀 행 스타일 하이패스(정상매출) */
		.my-row-style4 {
			color:black;
		}
		
		/* rownum 칼럼 색상 고정하는 경우 */
		.aui-grid-row-num-column {
		    color: #000000;
		}	
					
	</style>
	
	
	<script type="text/javascript">
		var auiGrid;
		$(document).ready(function() {
			
			createAUIGrid();
			fnInitDate();
			goSearchCard(); //카드선택리스트 가져오기
		});


		function createAUIGrid() {
			var gridPros = {
				// 체크박스 출력 여부
				showRowCheckColumn : true,
				// 전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
				// Row번호 표시 여부
				showRowNumColum : true,
				showFooter : true,
				footerPosition : "top",
				
				// row Styling 함수
				rowStyleFunction : function(rowIndex, item) {
					
					if(item.acnt_confirm_yn == "Y") {
						return "my-row-style1";
					}
					
					if(item.cancel_yn == "Y") {
						return "my-row-style2";
					}						
					else {
						if(item.hipass_yn == "N") {
							return "my-row-style3";
						}
						else {
							return "my-row-style4";
						}
					}
				}
				
			};

			var columnLayout = [
				{
					headerText : "카드번호",
					dataField : "card_no",
					width : "10%",
					style : "aui-center aui-popup",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
					     return $M.creditCardFormat(value); 
					},
					editable : true
				},
				{
					headerText : "하이패스여부",
					dataField : "hipass_yn",
					visible : false
				},	
				{
					headerText : "ibk카드승인순번",
					dataField : "ibk_ccm_appr_seq",
					visible : false
				},
				
				{
					headerText : "승인일시",
					dataField : "approval_date",
 					dataType : "date",
					width : "10%",
 					formatString : "yy-mm-dd HH:MM:ss"
				},
				{
					headerText : "승인번호",
					dataField : "approval_no",
					visible :false
				},
				{
					headerText : "구분",
					dataField : "card_use_name",
					width : "7%",
				},
				{
					headerText : "가맹점명",
					dataField : "chain_nm",
					width : "15%",
					style : "aui-left"
				},				
				{
					headerText : "승인금액",
					dataField : "approval_amt",
					dataType : "numeric",
					width : "7%",
					formatString : "#,##0",
					style : "aui-right"
				},
				{
					headerText : "공급가",
					dataField : "supply_amt",
					dataType : "numeric",
					width : "7%",
					formatString : "#,##0",
					style : "aui-right"
				},
				{
					headerText : "부가세",
					dataField : "vat_amt",
					dataType : "numeric",
					width : "7%",
					formatString : "#,##0",
					style : "aui-right"
				},
				{
					headerText : "회계확인여부",
					dataField : "acnt_confirm_yn",
					visible : false
				},				
				{
					headerText : "사용자",
					dataField : "mem_name",
					width : "7%",
					style : "aui-center"
				},
				{
					headerText : "취소여부",
					dataField : "cancel_yn",
					width : "7%",
					style : "aui-center"
				},
				{
					headerText : "비고",
					dataField : "remark",
					style : "aui-left"
				}
			];


			// 푸터 설정
			var footerLayout = [
				{
					labelText : "합계",
					positionField : "chain_nm"
				},
				{
					dataField : "approval_calc_amt",
					positionField : "approval_amt",
// 					operation : "SUM",
					formatString : "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGrid);
						var sum = 0;
						
						for (var i = 0; i < gridData.length; i++) {
							sum += gridData[i].approval_amt;
						}
						
						return sum;
					}
				},
				{
					dataField : "supply_calc_amt",
					positionField : "supply_amt",
// 					operation : "SUM",
					formatString : "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGrid);
						var sum = 0;
						
						for (var i = 0; i < gridData.length; i++) {
							sum += gridData[i].supply_amt;
						}
						
						return sum;
					}
				},
				{
					dataField : "vat_calc_amt",
					positionField : "vat_amt",
// 					operation : "SUM",
					formatString : "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGrid);
						var sum = 0;
						
						for (var i = 0; i < gridData.length; i++) {
							sum += gridData[i].vat_amt;
						}
						
						return sum;
					}
				},
			];

			// 실제로 #grid_wrap에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 푸터 레이아웃 세팅
			AUIGrid.setFooter(auiGrid, footerLayout);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == "card_no") {
					
					param = {
							"ibk_ccm_appr_seq" : event.item.ibk_ccm_appr_seq 						
					};	
				
					var poppupOption = "";
					$M.goNextPage('/mmyy/mmyy0105p01', $M.toGetParam(param), {popupStatus : poppupOption});
				}
			});
		}
		
		function goSearch() {
		
			if($('#s_card_no option').length < 1){
				alert('선택할 값이 없습니다.');
				return;
			}
			
			if($M.checkRangeByFieldName("s_start_dt", "s_end_dt", true) == false) {				
				return;
			}; 
			
			var param = {
				s_start_dt : $M.getValue("s_start_dt"),
				s_end_dt : $M.getValue("s_end_dt"),
				s_hipass_yn : $M.getValue("s_hipass_yn"),
				s_card_no : $M.getValue("s_card_no"),
				s_sort_key : "approval_date",
				s_sort_method : "asc"
			};
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
					};
				}
			);
		}
		
		// 검색 시작일자 세팅 현재날짜의 20일전
		function fnInitDate() {
			var now = "${inputParam.s_current_dt}";
			$M.setValue("s_start_dt", $M.addDates($M.toDate(now), -20));
		}
		

		//카드선택리스트 가져오기 ( default : 전체)
		function  goSearchCard() {			
			var param = {
					s_hipass_yn : $M.getValue("s_hipass_yn")
			};
			
			$M.goNextPageAjax(this_page+"/searchcard", $M.toGetParam(param), {method : 'get'},
				function(result) {
				
					$("select#s_card_no option").remove();	
		    		if(result.success) {
		    			
		    			//관리부는 카드 전체내역 조회
		    			if( '${page.fnc.F00016_001}' == 'Y' ){
		    				$('#s_card_no').append('<option value="" >- 전체 -</option>');	
		    			}

						//사용자별 카드선택 리스트 적용
		    			for(i = 0; i< result.list.length; i++){       		    				
			    			var optVal = result.list[i].card_no;
			    			var optText = $M.creditCardFormat(result.list[i].card_no) + '  ' + result.list[i].card_user_name;
			    			$('#s_card_no').append('<option value="'+ optVal +'">'+ optText +'</option>');			    			
		                }
						goSearch();
					}
				}
			);	
		}
		

		function fnDownloadExcel() {
			  // 엑셀 내보내기 속성
			  var exportProps = {
			         // 제외항목
			         //exceptColumnFields : ["removeBtn"]
			  };
			  fnExportExcel(auiGrid, "법인카드사용이력", exportProps);
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
					<table class="table">
						<colgroup>
							<col width="60px">
							<col width="260px">
							<col width="70px">
							<col width="320px">
							<col width="">
						</colgroup>
						<tr>
							<th>사용기간</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-5">
										<div class="input-group">
											<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" alt="조회 시작일" >
										</div>
									</div>
									<div class="col-auto">~</div>
									<div class="col-5">
										<div class="input-group">
											<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="조회 완료일" value="${inputParam.s_end_dt}">
										</div>
									</div>
								</div>
								
							</td>
							<th>카드구분</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-4">
										<select class="form-control" id="s_hipass_yn" name="s_hipass_yn" onchange="javascript:goSearchCard();" >
											<option value="" >- 전체 -</option>
											<option value="N" >법인카드 </option>
											<option value="Y" >하이패스</option>
										</select>
									</div>
									<div class="col-8">
										<select class="form-control" id="s_card_no" name="s_card_no" ></select>
									</div>
								</div>
							</td>
							<td>
								<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
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
				<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
	<!-- 그리드 서머리, 컨트롤 영역 -->
				<div class="btn-group mt5">
					<div class="left">
						총 <strong class="text-primary" id="total_cnt" >0</strong>건
					</div>						
					<div class="right">
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