<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 고객관리 > 홈페이지 문의관리 > null > null
-- 작성자 : 박예진
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function() {
			createAUIGrid();
// 			fnInit();
			goSearch();
		});
			
// 		function fnInit() {
// 			var now = "${inputParam.s_current_dt}";
// 			$M.setValue("s_start_dt", $M.addMonths($M.toDate(now), -3));
// 		}
			
		function goSearch() {
			var frm = document.main_form;
			//validationcheck
			if($M.validation(frm,
					{field:["s_start_dt", "s_end_dt"]})==false) {
				return;
			};

			var param = {
					"s_start_dt" : $M.getValue("s_start_dt"),
					"s_end_dt" : $M.getValue("s_end_dt"),
					"s_home_cs_type_cd" : $M.getValue("s_home_cs_type_cd"),
					"s_proc_gubun_cd" : $M.getValue("s_proc_gubun_cd"),
					"s_sort_key" : "reg_date",
					"s_sort_method" : "desc",
					"s_masking_yn" : $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N"
				};
				_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
				$M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method : 'get'},
					function(result) {
						if(result.success) {
							$("#total_cnt").html(result.total_cnt);
							AUIGrid.setGridData(auiGrid, result.list);
						}
					}
				);
		}
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn: true,
				enableFilter :true,
			};
			var columnLayout = [
				{ 
					headerText : "등록일시", 
					dataField : "reg_date", 
					dataType : "date",
					formatString : "yy-mm-dd HH:MM:ss",
					width : "150",
					minWidth : "150",
					style : "aui-center",               
					filter : {
		                  showIcon : true
		            }
				},
				{
					headerText : "게시판구분", 
					dataField : "home_cs_type_name", 
					width : "75",
					minWidth : "75",
					style : "aui-center"
				},
				{
					dataField : "home_cs_type_cd", 
					visible : false
				},
				{
					dataField : "seq_no", 
					visible : false
				},
				{
					headerText : "고객명", 
					dataField : "reg_name", 
					width : "150",
					minWidth : "150",
					style : "aui-center",               
					filter : {
		                  showIcon : true
		            }
				},
				{
					headerText : "연락처", 
					dataField : "hp_no", 
					width : "130",
					minWidth : "130",
					style : "aui-center",               
					filter : {
		                  showIcon : true
		            }
				},
				{
					headerText : "장비", 
					dataField : "maker_name", 
					width : "150",
					minWidth : "150",
					style : "aui-center",
				},
				{
					headerText : "모델명", 
					dataField : "model_name", 
					width : "120",
					minWidth : "120",
					style : "aui-left",
				},
				{
					headerText : "제목", 
					dataField : "title", 
					width : "360",
					minWidth : "150",
					style : "aui-left aui-popup",
				},
				{
					headerText : "처리구분", 
					dataField : "proc_gubun_cd", 
					width : "70",
					minWidth : "70",
					style : "aui-center",               
					filter : {
		                  showIcon : true
		            }
				},
				{
					headerText : "처리자", 
					dataField : "reg_mem_name", 
					style : "aui-center", 
					width : "80",
					minWidth : "80",      
					filter : {
		                  showIcon : true
		            }
				}
			];
			
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
			AUIGrid.bind(auiGrid, "cellClick", function(event){
				var frm = document.main_form;
				if(event.dataField == "title") {
					var param = {
						"home_cs_type_cd" : event.item["home_cs_type_cd"],
						"seq_no" : event.item["seq_no"],
						"proc_gubun_cd" : event.item["proc_gubun_cd"]
					};
					var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=850, height=460, left=0, top=0";
					$M.goNextPage('/cust/cust0402p01', $M.toGetParam(param), {popupStatus : poppupOption});  
				}
			});
		}
		
		// 엑셀다운로드
		function fnDownloadExcel() {
			  // 엑셀 내보내기 속성
			  var exportProps = {
					  
					  };
			  fnExportExcel(auiGrid, "홈페이지 문의관리", exportProps);
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
								<col width="65px">
								<col width="100px">
								<col width="55px">
								<col width="100px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th>등록일</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" required="required" alt="시작일" value="${searchDtMap.s_start_dt}">
												</div>
											</div>
											<div class="col-auto">~</div>
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" value="${searchDtMap.s_end_dt}" required="required" alt="종료일">
												</div>
											</div>
											<jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp">
				                     		<jsp:param name="st_field_name" value="s_start_dt"/>
				                     		<jsp:param name="ed_field_name" value="s_end_dt"/>
				                     		<jsp:param name="click_exec_yn" value="Y"/>
				                     		<jsp:param name="exec_func_name" value="goSearch();"/>
				                     		</jsp:include>	
										</div>
									</td>
									<th>게시판구분</th>
									<td>
										<select class="form-control width140px" id="s_home_cs_type_cd" name="s_home_cs_type_cd">
											<option value="">- 전체 -</option>
											<c:forEach var="item" items="${codeMap['HOME_CS_TYPE']}">
											<option value="${item.code_value}">${item.code_name}</option>
											</c:forEach>
										</select>
									</td>						
									<th>처리구분</th>
									<td>
										<select class="form-control" id="s_proc_gubun_cd" name="s_proc_gubun_cd">
											<option value="">- 전체 -</option>
											<option value="완결">완결</option>
											<option value="미결">미결</option>
										</select>
									</td>
									<td class="">
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
									</td>
								</tr>								
							</tbody>
						</table>
					</div>
<!-- /기본 -->	
<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<h4>고객문의내역</h4>
						<div class="btn-group">
							<div class="right">
								<c:if test="${page.add.POS_UNMASKING eq 'Y'}">
								<div class="form-check form-check-inline">
									<input  class="form-check-input"  type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" >
									<label  class="form-check-input"  for="s_masking_yn" >마스킹 적용</label>
								</div>
								</c:if>
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
							</div>
						</div>
					</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->					

					<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>

<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">0</strong>건
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