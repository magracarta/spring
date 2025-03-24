<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 서비스관련코드 > 고장부위코드관리 > null > null
-- 작성자 : 황빛찬
-- 최초 작성일 : 2020-03-16 10:48:19
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
		
		// 조회
		function goSearch() {
			var param = {
					"s_sort_key" : "sort_no",
					"s_sort_method" : "asc"
				};
			
				$M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method : 'get'},
					function(result) {
						if(result.success) {
							var frm = document.main_form;							
							AUIGrid.setGridData(auiGrid, result.list);
							AUIGrid.expandAll(auiGrid);
						}
					}
				);
		}
		
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "break_part_seq",
				displayTreeOpen : false,
				rowCheckDependingTree : true,
				showRowNumColumn: false,
				enableFilter :true,
				treeColumnIndex : 1,
			};
			
			var columnLayout = [
				{ 
					headerText : "관리코드", 
					dataField : "break_part_seq", 
					width : "20%",
					style : "aui-center",
					editable : false,
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "고장부위", 
					dataField : "break_part_name", 
					style : "aui-left aui-link",
					editable : false,
					filter : {
						showIcon : true
					},
				},
				{
					headerText : "사용여부",
					dataField : "use_yn",
					width : "15%",
					style : "aui-center",
					editable : false,
					filter : {
						showIcon : true
					},
				}
			];
			
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
			// 그리드 셀 클릭시
			AUIGrid.bind(auiGrid, "cellClick", function(event){
				var param = {
					"break_part_seq" : event.item["break_part_seq"]
				};
				goSearchDetail(param);      
			});
		}
		
		// 그리드 셀 클릭시 상세조회
		function goSearchDetail(param) {
			// break_part_seq 없으면 return
			if(param == null) {
				return;
			}
			
			$M.goNextPageAjax(this_page + "/" + param.break_part_seq, '', { method : 'get'},
					function(result) {
						if(result.success) { 
							var frm = document.main_form;
// 							$("#break_part_code").attr("readonly", true);
							var bean = result.bean;
							// 정보 세팅
							$M.setValue(bean);
						}
					}
				);
		}
		
	   // 신규 등록
	   function fnNew() {
		    var frm = document.main_form;
			$("#break_part_code").removeAttr("readonly");
			
			var setParam = {
				"break_part_seq" : "",
				"break_part_code" : "",
				"break_part_name" : "",
				"up_break_part_seq" : "",
				"sort_no" : "",
				"use_yn" : "Y"
			};
			
			$M.setValue(setParam);
			AUIGrid.clearSelection(auiGrid);
		}
	   
	   // 저장
	   function goSave() {
			var frm = document.main_form;
		
			// validation check
			if($M.validation(document.main_form, {field:["break_part_code", "break_part_name", "up_break_part_seq", "sort_no", "use_yn"]}) == false) {
				return;
			};
			
			$M.goNextPageAjaxSave(this_page + '/save', $M.toValueForm(frm) , {method : 'POST'},
					function(result) {
						if(result.success) {
							$M.goNextPage(this_page, '', '');
// 							goSearch();
						}
					}
				);
		}
	   
	</script>
</head>
<body style="background : #fff">
<form id="main_form" name="main_form">
<!-- contents 전체 영역 -->
			<div class="content-box" >
				<div class="contents">
					<div class="row">
<!-- 메뉴목록 -->
						<div class="col-4">
							<div class="title-wrap mt10">
								<div class="btn-group">
								<h4>분류목록</h4>
									<div class="right">
										<button type="button" onclick=AUIGrid.expandAll(auiGrid); class="btn btn-default"><i class="material-iconsadd text-default"></i>전체펼치기</button>
										<button type="button" onclick=AUIGrid.collapseAll(auiGrid); class="btn btn-default"><i class="material-iconsremove text-default"></i>전체접기</button>
									</div>
								</div>						
							</div>
							<div id="auiGrid" style="margin-top: 5px;height: 555px;"></div>
						</div>
						<!-- /메뉴목록 -->						
						<div class="col-3">
							<div class="row">
								<!-- 메뉴정보 -->						
										
								<div class="col-12">
									<div class="title-wrap mt10">
										<h4>고장부위정보</h4>					
									</div>									
									<!-- 폼테이블 -->	
									<div>
										<table class="table-border mt5">
											<colgroup>
												<col width="100px">
												<col width="">
											</colgroup>
											<tbody>
												<tr>
													<th class="text-right essential-item">고장코드</th>
													<td>
														<input type="text" class="form-control essential-bg width60px" id="break_part_code" name="break_part_code" alt="고장코드" maxlength="2" datatype="int">
														<input type="hidden" class="form-control essential-bg width60px" id="break_part_seq" name="break_part_seq" alt="고장코드">
													</td>
												</tr>
												<tr>
													<th class="text-right essential-item">고장부위명</th>
													<td>
														<input type="text" class="form-control essential-bg width200px" name="break_part_name" maxlength="100" alt="고장명">
													</td>
												</tr>		
												<tr>
													<th class="text-right essential-item">상위코드</th>
													<td>
													<select class="form-control essential-bg width280px" id="up_break_part_seq" name="up_break_part_seq" alt="상위코드">
														<option value="" >- 전체 -</option>
														<c:forEach var="item" items="${list}">
															<option value="${item.up_break_part_seq}" >${item.path_break_part_name}</option>
														</c:forEach>
													</select>
													</td>
												</tr>	
												<tr>
													<th class="text-right essential-item">정렬순서</th>
													<td>
														<input type="text" class="form-control essential-bg width40px" name="sort_no" datatype="int" alt="정렬순서">
													</td>
												</tr>																																	
												<tr>
													<th class="text-right essential-item">사용여부</th>
													<td>
														<div class="form-check form-check-inline">
															<input class="form-check-input" type="radio" name="use_yn" value="Y" alt="사용여부">
															<label class="form-check-label">Y</label>
														</div>
														<div class="form-check form-check-inline">
															<input class="form-check-input" type="radio" name="use_yn" value="N">
															<label class="form-check-label">N</label>
														</div>
													</td>
												</tr>
											</tbody>
										</table>
									</div>
									<!-- /폼테이블 -->
<!-- 그리드 서머리, 컨트롤 영역 -->
									<div class="btn-group mt5 section-inner active">					
										<div class="right">
											<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
										</div>
									</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
								</div>
<!-- /메뉴정보 -->									
							</div>
						</div>
					</div>
				</div>
			</div>
<!-- /contents 전체 영역 -->	
</form>
</body>
</html>