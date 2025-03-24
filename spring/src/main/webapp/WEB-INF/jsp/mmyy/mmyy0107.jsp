<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > null > null > 비상연락망
-- 작성자 : 손광진
-- 최초 작성일 : 2020-04-09 13:14:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		
		$(document).ready(function() {
			createLeftAUIGrid();
			createRightAUIGrid();
			goSearch();
		});
		
		function goSearch(getParam) {
			
			var orgCode = "";
			
			if($M.nvl(getParam, "") != "") {
				orgCode = $M.nvl(getParam.org_code, "");
			};

			var param = {
				"s_kor_name" 		: $M.getValue("s_kor_name"),
				"s_org_code" 		: orgCode,
				"s_hp_no" 			: $M.getValue("s_hp_no"),
				// "s_work_status_cd"  : $M.getValue("s_work_status_cd"),
				"s_masking_yn" : $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N",
				"s_sort_key" 		: "grade_cd desc nulls last, kor_name",
				"s_sort_method" 	: "asc",
				
			};
			
			console.log(param);
			$M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGridRight, result.list);
					};
				}
			);
		}
		
		function createLeftAUIGrid() {
			var gridPros = {
				rowIdField : "org_code",
				height : 550,
				displayTreeOpen : false,
				rowCheckDependingTree : true,
				showRowNumColumn: false,
				enableFilter :true,
				treeColumnIndex : 1,
			};
			var columnLayout = [
				{ 
					headerText : "조직코드", 
					dataField : "org_code", 
					width : "70",
					minWidth : "55",
					style : "aui-center",
					editable : false,
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "조직", 
					dataField : "org_name", 
					width : "170",
					minWidth : "55",
					style : "aui-left aui-link",
					editable : false,
					filter : {
						showIcon : true
					},
				},
				{
					headerText : "조직구분", 
					dataField : "org_gubun_name", 
					width : "70",
					minWidth : "55",
					style : "aui-center",
					editable : false,
					filter : {
						showIcon : true
					}
				}
			];
			
			auiGridLeft = AUIGrid.create("#auiGridLeft", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridLeft, listJson);
			AUIGrid.expandAll(auiGridLeft);
			$("#auiGridLeft").resize();
			AUIGrid.bind(auiGridLeft, "cellClick", function(event) {
				if(event.treeIcon === true) {
					return;
				};
				var param = {
					"org_code" : event.item["org_code"],
					"s_masking_yn" : $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N"
				};
				goSearch(param);      
			});
		}
		
		function createRightAUIGrid() {
			var gridPros = {
				rowIdField : "mem_no",
				height : 550,
				showRowNumColumn: true,
				fillColumnSizeMode : false
			};
			var columnLayout = [
				{    
					headerText : "부서", 
					dataField : "org_kor_name", 
					width : "110",
					minWidth : "80",
					style : "aui-center",
				},
				{    
					headerText : "직원명", 
					dataField : "kor_name", 
					width : "90",
					minWidth : "90",
					style : "aui-center aui-popup",
				},
				{    
					headerText : "직책",
					dataField : "grade_name", 
					width : "70",
					minWidth : "70",
					style : "aui-center",
				},
				{    
					headerText : "직급",
					dataField : "job_name", 
					width : "70",
					minWidth : "70",
					style : "aui-center",
				},
				{    
					headerText : "휴대폰", 
					dataField : "hp_no", 
					width : "110",
					minWidth : "110",
					style : "aui-center",
				},
				{    
					headerText : "이메일", 
					dataField : "email", 
					width : "210",
					minWidth : "10",
					style : "aui-center  aui-popup",
				},
				{    
					headerText : "비상연락처", 
					dataField : "emergency_contact_phone_no", 
					width : "110",
					minWidth : "10",
					style : "aui-center",
				},
				{    
					headerText : "비상연락처(관계)", 
					dataField : "emergency_contact_relation", 
					width : "100",
					minWidth : "10",
					style : "aui-center",
				},
				/* {    
					headerText : "자택주소", 
					dataField : "home_addr", 
					width : "30%",
					style : "aui-left",
				}, */
				{    
					headerText : "재직구분", 
					dataField : "work_status_name", 
					style : "aui-center",
					width : "70",
					minWidth : "70",
				},
			];
			
			auiGridRight = AUIGrid.create("#auiGridRight", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridRight, []);
			$("#auiGridRight").resize();
			AUIGrid.bind(auiGridRight, "cellClick", function(event) {
				if(event.dataField == "email") {
					var param = {
						"to" : event.item["email"]
					};
					openSendEmailPanel($M.toGetParam(param));
				} else if(event.dataField == "kor_name") {
					var param = {
							"s_mem_no" 		: event.item.mem_no,
							"search_type" 	: "P",
					};
					var poppupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1350, height=470, left=0, top=0";
					$M.goNextPage('/comm/comm0116', $M.toGetParam(param), {popupStatus : poppupOption});
				};		      
			});
		}
		
		function enter(fieldObj) {
			var field = ["s_kor_name", "s_hp_no"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch(document.main_form);
				};
			});
		}
		
		//엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGridRight, "YK 비상연락망", "");
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
									<col width="70px">
									<col width="100px">
									<col width="70px">
									<col width="100px">
									<col width="*">
								</colgroup>
								<tbody>
									<tr>	
										<th>직원명</th>
										<td>
											<input type="text" id="s_kor_name" name="s_kor_name" class="form-control">
										</td>
										
										<th>휴대폰</th>
										<td>
											<input type="text" id="s_hp_no" name="s_hp_no" class="form-control" placeholder="-없이 숫자만" size="5" datatype="int">
										</td>
										<%-- 
										<th>재직구분</th>
										<td>
											<select class="form-control" id="s_work_status_cd" name="s_work_status_cd">
												<option value="">- 전체 -</option>
												<c:forEach var="list" items="${codeMap['WORK_STATUS']}">
													<option value="${list.code_value}">${list.code_name}</option>
												</c:forEach>
											</select>
										</td>
														 --%>	
										<td>
											<button type="button" class="btn btn-important" style="width: 50px;"  onclick="javascript:goSearch();">조회</button>
										</td>
									</tr>								
								</tbody>
							</table>
						</div>
						<!-- /검색영역 -->	
						<!-- 하단 폼테이블 -->		
						<div class="row">					
						<!-- 좌측 폼테이블 -->
							<div class="col-3">
								<!-- 조직도 -->
								<div class="title-wrap mt10">
									<h4>조직도</h4>
									<div class="btn-group">
									<div class="right">
										<button type="button" onclick=AUIGrid.expandAll(auiGridLeft); 	class="btn btn-default"><i class="material-iconsadd text-default"></i>전체펼치기</button>
										<button type="button" onclick=AUIGrid.collapseAll(auiGridLeft); class="btn btn-default"><i class="material-iconsremove text-default"></i>전체접기</button>
									</div>
								</div>		
								</div>
								<div id="auiGridLeft" style="margin-top: 5px; height: 555px;"></div>
								<div class="btn-group mt5">
									<div class="left">
										<!-- 총 <strong class="text-primary" id="total_cnt">0</strong>건 --> 
									</div>						
								</div>
								<!-- /조직도 -->
							</div>
							<!-- /좌측 폼테이블 -->
						
							<!-- 우측 폼테이블 -->
							<div class="col-9">
								<!-- 조회결과 -->
								<div class="title-wrap mt10">
									<h4>조회결과</h4>
									<div class="right">
										<c:if test="${page.add.POS_UNMASKING eq 'Y'}">
										<div class="form-check form-check-inline">
											<input  class="form-check-input"  type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" >
											<label  class="form-check-input"  for="s_masking_yn" >마스킹 적용</label>
										</div>
										</c:if>
										<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
									</div>
								</div>
								<div id="auiGridRight" style="margin-top: 5px; height: 555px;"></div>
								<!-- /조회결과 -->
								<div class="btn-group mt5">		
									<div class="left">
										총 <strong class="text-primary" id="total_cnt">0</strong>건
									</div>
								</div>
							</div>
							<!-- /우측 폼테이블 -->
						</div>
						<!-- /하단 폼테이블 -->	
					</div>	
				</div>
					<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>		
			</div>
			<!-- /contents 전체 영역 -->
		</div>	
	</form>
</body>
</html>